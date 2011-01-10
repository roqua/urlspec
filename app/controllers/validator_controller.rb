class ValidatorController < ApplicationController
  def go
    @ggz_name   = (CGI.unescape(params["ggzname"])    || "").strip
    @secret     = "b157e03f434fd547e6085d70006c19ad6494a80c0b2e0147e5fb60cc03a882250"
    @profess_id = (CGI.unescape(params['userid'])     || "").strip
    @patient_id = (CGI.unescape(params['clientid'])   || "").strip
    @timestamp  = (CGI.unescape(params['timestamp'])  || "").strip
    @token      = (CGI.unescape(params['token'])      || "").strip
    @version    = (CGI.unescape(params['version'])    || "1").strip

    # if people dont url-encode their params, we get a space instead of a + in the timestamp, for the TZ
    @timestamp  = @timestamp.gsub(/\s(\d\d:?\d\d)$/, '+\1')
    
    @errors = Array.new

    ############################################################## STEP ONE: CHECK REQUIRED PARAMETERS

    @errors << "ERROR: userid parameter missing or empty."    if @profess_id.blank?
    @errors << "ERROR: clientid parameter missing or empty."  if @patient_id.blank?
    @errors << "ERROR: timestamp parameter missing or empty." if @timestamp.blank?
    @errors << "ERROR: token parameter missing or empty."     if @token.blank?

    if not @errors.empty?
      # no point going on
      return
    end

    ############################################################## STEP TWO: VALIDATE TOKEN

    # Validate hash
    case @version
    when "1"
      @plain_token = [
        @ggz_name, 
        @secret, 
        @timestamp, 
        @profess_id, 
        @patient_id, 
        @version
      ].join('|').downcase
    else
      @errors << "Unknown version"
    end

    @new_token = Digest::SHA1.hexdigest(@plain_token)

    if @new_token != @token
      @errors << "Token does not validate"
      return
    end

    ############################################################# VALIDATE TIMESTAMP

    @parsed_time = Time.parse(@timestamp)

    if not @timestamp =~ /^\d\d\d\d-?\d\d-?\d\d[tT ]?\d?\d:?\d\d/ or not @parsed_time
      @errors << "Could not parse timestamp you gave us"
      return
    end

    # if parsed time is 600 seconds ago, or 600 seconds in the future, fail
    # (in reality, this window is configurable)
    if @parsed_time < 600.seconds.ago or 600.seconds.from_now < @parsed_time
      @errors << "Authentication error: Request expired"
      @errors << "I see #{@parsed_time.inspect}, which is #{Time.now - @parsed_time} seconds from/till now (#{Time.now.inspect})"
      return
    end

    #####################################################################
    #
    # if you get here, you're all good.

  end

end
