Your task is to build a bot in Ruby, that triggers searches on https://www.thetrainline.com and returns the results in a specific format.

## Input

* The bot should respond to `Scraper::Thetrainline.find(from, to, departure_at)`
* Assume that the parameters `from` and `to` will be EXACTLY what you need
* `departure_at` will be a Ruby DateTime object.
* You do not need to solve any of the anti-bot logic they have, it's fine to use a local static version of the data you need

## Output

* `find()` should return an array
* Each element of the array should be an option for a trip
* E.g. If you search for London to Paris, and they give you 10 "segments" leaving each hour on the hour, the array size should be 10
( Each "segment" should be in this format, and should include all relevant data for the segement and any associated fares:

```ruby
# Segment
{
      :departure_station => "Ashchurch For Tewkesbury",
           :departure_at => #<DateTime: 2025-04-26T06:09:00+00:00 ((2456774j,22140s,0n),+0s,2299161j)>,
        :arrival_station => "Ash",
             :arrival_at => #<DateTime: 2025-04-26T09:37:00+00:00 ((2456774j,34620s,0n),+0s,2299161j)>,
       :service_agencies => ["thetrainline"],
    :duration_in_minutes => 208,
            :changeovers => 2,
               :products => ["train"],
                  :fares => [...] # See below
}

# Fare
{
                       :name => "Advance Single",
             :price_in_cents => 1939,
                   :currency => "GBP",
                             ...
},
```

My takes:

Nice challenge, put me to think.
Live Capybara parsing is slow because DOM is dynamic and constantly rehydrating.
Fixture parsing is insanely fast because Nokogiri is stable and instantaneous.

TODO:
- Places lookup
- Tests
- Separate parser from scraper


fixture.rb test I’ve separated fixture extraction, and I’d either stub Capybara or cover it with a higher-level integration test. For now I’ve focused on unit-ish specs using the saved fixture.”

extra params
- use_fixture?
- save_fixture?
- headless?

Runs only in headless=false and requires solving the captcha. If headless=true script cannot solve captcha and will fail.
noticed different search pages based on location (it will break, it was developed in germany)