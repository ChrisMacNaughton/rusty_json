require 'spec_helper'
require 'pry'
describe RustyJson do
  it 'has a version number' do
    expect(RustyJson::VERSION).not_to be nil
  end

  it 'parses json' do
    json = '{"name":"test"}'
    parsed = RustyJson.parse(json)
    rust = <<-RUST
struct JSON {
  name: String,
}
      RUST
    expect(parsed).to eq(rust)
  end

  it 'removes bad key names' do
    json = '{"mutex-FileJournal::completions_lock": { "wait": { "avgcount": 0,"sum": 0.000000000}}}'

    rust = <<-RUST
struct Wait {
  avgcount: i64,
  sum: f64,
}

struct MutexFilejournalCompletionsLock {
  wait: Wait,
}

struct JSON {
  mutex_FileJournal_completions_lock: MutexFilejournalCompletionsLock,
}
    RUST
    expect(RustyJson.parse(json)).to eq(rust)
  end

  it 'can print the struct twice' do
    json = '{"name":"test"}'
    rust = <<-RUST
struct JSON {
  name: String,
}
      RUST
    expect(RustyJson.parse(json)).to eq(rust)
    expect(RustyJson.parse(json)).to eq(rust)
  end

  it 'parses nested json' do
    json = '{"test":{"value":"string"}}'
    parsed = RustyJson.parse(json)

    rust = <<-RUST
struct Test {
  value: String,
}

struct JSON {
  test: Test,
}
    RUST
    expect(parsed).to eq(rust)
  end

  it 'parses arrays' do
    json = '{"key":[1,2,3]}'
    parsed = RustyJson.parse(json)

    rust = <<-RUST
struct JSON {
  key: Vec<i64>,
}
    RUST
    expect(parsed).to eq(rust)
  end

  it 'parses integers' do
    json = '{"test":64}'
    parsed = RustyJson.parse(json)

    rust = <<-RUST
struct JSON {
  test: i64,
}
    RUST
    expect(parsed).to eq(rust)
  end


  it 'can handle a recursive reference' do
    json = '{"key": {"key": {"key": {"key": 12}}}}'
    parsed = RustyJson.parse(json)
    rust = <<-RUST
struct Key_3 {
  key: i64,
}

struct Key_2 {
  key: Key_3,
}

struct Key {
  key: Key_2,
}

struct JSON {
  key: Key,
}
    RUST

    expect(parsed).to eq(rust)
  end
end
