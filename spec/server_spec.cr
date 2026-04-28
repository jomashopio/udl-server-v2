require "./spec_helper"

def with_default_destination(value)
  original = ENV["DEFAULT_DESTINATION"]?
  ENV["DEFAULT_DESTINATION"] = value
  yield
ensure
  if original
    ENV["DEFAULT_DESTINATION"] = original
  else
    ENV.delete("DEFAULT_DESTINATION")
  end
end

def without_default_destination
  original = ENV["DEFAULT_DESTINATION"]?
  ENV.delete("DEFAULT_DESTINATION")
  yield
ensure
  ENV["DEFAULT_DESTINATION"] = original if original
end

describe "UDL Server" do
  context "success" do
    it "redirects root to DEFAULT_DESTINATION" do
      with_default_destination("https://example.com") do
        get "/"

        response.status_code.should eq(302)
        response.headers["Location"].should eq("https://example.com/")
      end
    end

    it "redirects path to DEFAULT_DESTINATION + path" do
      with_default_destination("https://example.com") do
        get "/watches/rolex"

        response.status_code.should eq(302)
        response.headers["Location"].should eq("https://example.com/watches/rolex")
      end
    end

    it "serves static apple-app-site-association file" do
      get "/.well-known/apple-app-site-association"

      response.status_code.should eq(200)
      response.headers["Content-Type"].should eq("application/json")
    end

    it "serves static assetlinks.json file" do
      get "/.well-known/assetlinks.json"

      response.status_code.should eq(200)
      response.headers["Content-Type"].should eq("application/json")
    end
  end

  context "failure" do
    it "renders fallback page if DEFAULT_DESTINATION is not set" do
      without_default_destination do
        get "/"

        response.status_code.should eq(200)
        response.body.should contain("Something went wrong")
        response.body.should contain("Check the server configuration for more details")
      end
    end

    it "renders fallback page for any path if DEFAULT_DESTINATION is not set" do
      without_default_destination do
        get "/about-us"

        response.status_code.should eq(200)
        response.body.should contain("Something went wrong")
        response.body.should contain("Check the server configuration for more details")
      end
    end
  end
end
