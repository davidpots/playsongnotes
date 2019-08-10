# frozen_string_literal: true

require "utils/curl"

describe "curl" do
  describe "curl_args" do
    it "returns -q as the first argument when HOMEBREW_CURLRC is not set" do
      # -q must be the first argument according to "man curl"
      expect(curl_args("foo").first).to eq("-q")
    end

    it "doesn't return -q as the first argument when HOMEBREW_CURLRC is set" do
      ENV["HOMEBREW_CURLRC"] = "1"
      expect(curl_args("foo").first).not_to eq("-q")
    end

    it "returns --retry when HOMEBREW_CURL_RETRIES is set" do
      ENV["HOMEBREW_CURL_RETRIES"] = "3"
      expect(curl_args("foo").join(" ")).to include("--retry 3")
    end
  end
end
