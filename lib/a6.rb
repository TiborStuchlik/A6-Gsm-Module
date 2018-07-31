# board: hw-549
# chip: A6
# manufactured: Ai Thinker Co.LTD
# firmware: V03.05.20170090814H38

require './lib/modem'

module Lib
  class A6
    attr_accessor :modem

    def initialize( p = 1, b = 115200)
      @modem = Modem.init( p, b)
    end

    def at
      ra = @modem.cmd "AT"
      ra.output = "Modem Ready"
    end

    def default
      ra = @modem.cmd "AT&F0"
      ra.output = "Set all current parameters to manufacturer defaults"
    end

    def info
      ra = @modem.cmd "ATI"
      rat = ra.reverse
      ra.output = [ "Chip: " + ra[3], "Manufactured: " + ra[2], "Firmware: " + ra[1] ].join("; ")
    end

    def packet_service(c = :attach) #attach or detach packet service
      case c
        when :attach; r = "=1"
        when :detach; r = "=0"
        when :get; r = "?"
        else r = "=?"
      end
      ra = @modem.cmd "AT+CGATT" + r
    end

    def define_pdp( cid, type, apn)
      ra = @modem.cmd "AT+CGDCONT=" + [ cid, type, apn].join(",")
    end

    def activate_pdp( a = :activate, cid = 1)
      case a
        when :activate; r = "=1"
        when :deactivate; r = "=0"
        when :get; r = "?"; cid = nil
        else r = "=?"
      end
      ra = @modem.cmd "AT+CGACT" + [ r, cid].join(",")
    end

    def signal
      ra = @modem.cmd "AT+CSQ"
      v_dbm = [-113,-111,-109,-107,-105,-103,-101,-99,-97,-95,-93,-91,-89,-87,-85,-83,-81,-79,-77,-75,-73,-71,-69,-67,-65,-63,-61,-59,-57,-55,-53,-51]
      ra.output = "Signal: " + v_dbm[ra.reverse[1].split(": ")[1].split(",")[0].to_i].to_s + " dBm"
    end

    def start_tcp( ip, port)
      ra = @modem.cmd "AT+CIPSTART=TCP," + [ ip, port].join(",")
    end

    def close_tcp
      ra = @modem.cmd "AT+CIPCLOSE"
    end

    def shut_tcp
      ra = @modem.cmd "AT+CIPSHUT"
    end

    def status
      ra = @modem.cmd "AT+CIPSTATUS"
    end

    def local_ip
      ra = @modem.cmd "AT+CIFSR"
    end

    def send
      ra = @modem.cmd "AT+CIPSEND", "> "
    end

    def write(data)
      ra = @modem.write(data)
    end

    def send_end
      ra = @modem.cmd 0x1a.chr, "OK"
      #TODO need restart modem here, otherwise modem halt.
      @modem.restart
      ra
    end

    def activate_gprs( pdp_type, apn)

    end

    def close
      @modem.close
    end
  end
end