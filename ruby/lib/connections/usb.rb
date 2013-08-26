class Connections::Usb
  ID_VENDOR_LEGO = 0x0694
  ID_PRODUCT_NXT = 0x0002
  OUT_ENDPOINT   = 0x01
  IN_ENDPOINT    = 0x82
  TIMEOUT        = 1000
  READSIZE       = 64
  INTERFACE      = 0

  def initialize(interface)
    @interface = interface || INTERFACE
    usb = LIBUSB::Context.new
    @usb_dev = usb.devices(idVendor: ID_VENDOR_LEGO, idProduct: ID_PRODUCT_NXT).first
    $stderr.puts "Cannot find usb device" if @usb_dev.nil?
    @usb = @usb_dev.open
    @usb.reset_device
    @usb.claim_interface(@interface)
  end

  def write(msg)
    @usb.bulk_transfer(endpoint: OUT_ENDPOINT, dataOut: msg.pack("C*"), timeout: TIMEOUT)
  end

  def read
    @usb.bulk_transfer(endpoint: IN_ENDPOINT, dataIn: READSIZE, timeout: TIMEOUT)
  end

  def close
    if @usb
      @usb.release_interface(@interface)
      @usb.close
      @usb_dev = @usb = nil
    end
  end

  def connected
    not not @usb
  end

  def type
    "USB"
  end

  def info
    @interface
  end
end
