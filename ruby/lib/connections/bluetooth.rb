class Connections::Bluetooth
  def initialize(dev)
    @connection_type = "serialport"
    @dev = dev
    @sp = SerialPort.new(dev, 57600, 8, 1, SerialPort::NONE)

    @sp.flow_control = SerialPort::HARD
    @sp.read_timeout = 5000
    $stderr.puts "Cannot connect to #{dev}" if @sp.nil?
  end

  def write(msg)
    msg = [(msg.size & 255),(msg.size >> 8)] + msg
    msg.each do |b|
      @sp.putc b
    end
  end

  def read
    len_header = @sp.sysread(2)
    @sp.sysread(len_header.unpack("v")[0])
  end

  def close
    @sp.close if @sp and not @sp.closed?
  end

  def connected?
    not @sp.closed?
  end

  def type
    "Bluetooth"
  end

  def info
    @dev
  end
end
