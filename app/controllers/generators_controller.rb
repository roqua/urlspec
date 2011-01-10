class GeneratorsController < ApplicationController

  SECRET = "b157e03f434fd547e6085d70006c19ad6494a80c0b2e0147e5fb60cc03a882250"

  def new
    @secret = SECRET
  end

  def create
    # NOTE: Reference implementation, therefore we include comments which explain what some ruby
    # commands do

    @ggz_name   = (params["ggzname"]    || "").strip    # .strip gets rid of extra spaces at the start
    @profess_id = (params['userid']     || "").strip    # or at the end
    @patient_id = (params['clientid']   || "").strip
    @secret     = SECRET
    @version    = (params['version']    || "1").strip

    # I hate timezones, this gives me a UTC-based time, so that we can hardcode +00:00 offset
    @timestamp = Time.now.getgm.strftime("%Y-%m-%dT%H:%M:%S+00:00")

    @array_for_token = [
      @ggz_name,
      @secret,
      @timestamp,
      @profess_id,
      @patient_id,
      @version
    ]

    @string_for_token = @array_for_token.join("|").downcase
    @hashed_token     = Digest::SHA1.hexdigest(@string_for_token)
  end

end
