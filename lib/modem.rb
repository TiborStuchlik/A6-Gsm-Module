require 'serialport'

module Modem

  class << self
    attr_accessor :serial
    attr_accessor :modem
  end

  def self.init(p = 1, b = 115200)
    @port = p
    @baud = b
    @serial = SerialPort.new(p - 1, b, 8, 1, SerialPort::NONE)
    @serial.read_timeout = 500
    @modem = Mdm.new(@serial)
  end

  def self.restart
    puts "Restarting modem..."
    t = @serial.read_timeout
    @serial.close
    @serial = SerialPort.new( @port - 1, @baud, 8, 1, SerialPort::NONE)
  end

  class MdmResultArray < Array
    attr_accessor :output

    def initialize
      super
    end

    def to_s
      return @output if @output
      return "Command: " + self.join(", ") if self.size > 0
      return "EMPTY"
    end
  end

  class Mdm

    attr_accessor :serial

    def initialize(s)
      @serial = s
    end

    def write(data)
      @serial.write(data)
    end

    def cmd( c, r = "OK", e = /ERROR:\d{1,3}\z/, t = 500, rp = 2, rw = 0.1)
      res = false
      resa = []
      @serial.read_timeout = t
      rp.times do |count|
       @serial.write(c + "\r")
       #sleep( rw)
       res, resa = cmd_response( r, e, t)
       if res
         break
       else
         restart
       end
      end
      if !res
        raise "Modem Error on Command: " + c + " with message: " + resa.last.to_s
      end
      resa
    end

    def restart
      @serial = Modem.restart
    end

    def close
      @serial.close
    end

    private

    def cmd_response( r , e, t )
      buf = MdmResultArray.new
      st = (Time.new.to_f * 100).to_i
      while true
        begin
          resl = ""
          resl = @serial.readline
        rescue => err
          at = (Time.new.to_f * 100).to_i
          ams = at - st
          if ams > t
            buf << "Timeout: " + t.to_s
            return [ false, buf ]
          end
          puts "Wait for response: " + ams.to_s + "/" + t.to_s
          sleep(0.1)
        end
        res = resl.gsub("\n","").gsub("\r","")
        buf << res unless res.empty?
        if res == r
          return [ true, buf]
        elsif e.match(res)
          return [ false, buf]
        end
      end
    end


  end

end
