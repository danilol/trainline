# Scraper::Thetrainline

A Ruby scraper for [Trainline](https://www.thetrainline.com) platform that supports both **snapshot mode** (offline, requires pre-saved file) and **live browser mode** using **Capybara + Cuprite**.

This project was built for a take-home [challenge](input.MD).  
Not every part is perfect; some **TODOs** are intentionally left to demonstrate awareness of improvements that could be made with more time.

The public API required by the challenge:

```ruby
Scraper::Thetrainline.find(from, to, departure_at)
```

This returns an array of journey **Segment** objects.

---

## 🚀 Usage

```ruby
Scraper::Thetrainline.find(
  "London",
  "Paris",
  DateTime.parse("2025-11-20 09:00")
)

or

Scraper::Thetrainline.find(
  'Lisboa', 
  'Faro', 
  Date.today + 1
)
```

Returns:

```ruby
Array<Scraper::Thetrainline::Models::Segment>
```

Each `Segment` contains:

- `departure_station`
- `arrival_station`
- `departure_at`
- `arrival_at`
- `service_agencies`
- `duration_in_minutes`
- `changeovers`
- `products`
- `fares` — an array of `Fare` objects

Each `Fare` contains:

- `name`
- `price_in_cents`
- `currency`

---

## 📦 Installation

```bash
bundle install
```

---

## ⚙️ Environment Variables

### CREATE_SNAPSHOT_FILE

Automatically saves the scraped HTML to `fixtures/` when running in live mode.
```bash
CREATE_SNAPSHOT_FILE=false  # do not save snapshots (default)
CREATE_SNAPSHOT_FILE=true   # save HTML to fixtures/origin_destination.html

# Example:
CREATE_SNAPSHOT_FILE=true bundle exec ruby -e "require './lib/scraper/thetrainline'; Scraper::Thetrainline.find('Berlin', 'Munich', Date.today + 1)"
```

When enabled, successful live scrapes will generate a file in `fixtures/` with the format:
```
fixtures/origin_destination.html
```

For example:
- `fixtures/london_paris.html`
- `fixtures/berlin_munich.html`

This is useful for:
- Building a library of snapshots for testing
- Creating offline fixtures for faster development
- Debugging HTML structure changes

City names are automatically slugified (lowercased, accents removed, spaces converted to underscores).

### USE_SAVED_FILE

Controls whether the scraper loads static HTML snapshots or performs a real browser fetch.

```
USE_SAVED_FILE=false # launch browser and perform a real scrape (default)
USE_SAVED_FILE=true  # use offline pre-saved snapshots (recommended)

example:
USE_SAVED_FILE=true bundle exec ruby -e "require './lib/scraper/thetrainline'; Scraper::Thetrainline.find('Lisboa', 'Faro', Date.today + 1)"
```

Snapshot mode requires HTML files stored in `snapshots/`.  
This mode is **fast**, **reliable**, and offline.

There are 6 pre-saved files in fixture/ directory:

from 'London' to 'Paris'
from 'Munich' to 'Hamburg'
from 'Lisboa' to 'Faro'
from 'Paris' to 'Marseille'
from 'Roma' to 'Venezia'
from 'Warsaw' to 'Prague'

When trying to use a saved file that does not exist yet, you get the `Fixture not found` error.

---

### HEADLESS

An attempted feature — **currently unreliable** due to Trainline’s bot detection.

```
HEADLESS=false  # visible browser window (recommended) (default)
HEADLESS=true   # try headless mode (often blocked by Trainline)

example:
HEADLESS=true bundle exec ruby -e "require './lib/scraper/thetrainline'; Scraper::Thetrainline.find('London', 'Paris', Date.today + 1)"
```

A TODO exists in the code acknowledging this limitation.

---

## 🛂 CAPTCHA Handling

When running in **live** mode (`USE_SAVED_FILE=false`), Trainline may show a CAPTCHA.

If that happens:

➡️ **Solve it manually in the browser window**  
➡️ The scraper will continue automatically afterward

This is common for protected public websites.

---

## 🧪 Running Tests

Tests run **entirely using snapshot mode**, so no browser launches.

Run all tests:

```bash
bundle exec rspec
```

You will find tests covering:

- Models (`Segment`, `Fare`)
- The `Client` behavior in snapshot mode
- The `.find` entrypoint method

Live-browser scraping is intentionally not tested.

---

## 🗂 Project Structure

```
lib/
  scraper/
    thetrainline/
      client.rb
      live_fetcher.rb
      snapshot_fetcher.rb
      parser.rb
      url_builder.rb
      models/
        segment.rb
        fare.rb
    thetrainline.rb   # defines .find API
config/
  app_config.rb
snapshots/
spec/
```

---

## 📌 Notable TODOs / Improvements

These are intentionally left in the codebase to show awareness:

### Logging
A minimal logger exists.  
A more robust, structured logger could be built (log levels, file logging, etc.).

### HEADLESS Browser Mode
Not fully functioning. Due to time constraints and Trainline’s bot protection, it mostly works only in non-headless mode.

### More Robust Parsing
The HTML parser is built around current snapshot structure.  
Trainline HTML may change — a more resilient parser would use:

- CSS selectors with fallback
- Strict field validation
- Error reporting for missing fields

### More Tests
Given more time, useful additions would include:
- More detailed unit tests for parser edge cases
- Contract tests for snapshot structure
- Tests for error conditions
- Check Capybara's timeout configurable and its needs

---

## 🧾 License

MIT (or whatever license you prefer).

---

## 🙋 Contact

If you have questions, feel free to reach out!

