require 'spec_helper'

describe RustyJson do
  it 'has a version number' do
    expect(RustyJson::VERSION).not_to be nil
  end

  it 'parses json' do
    json = '{"name":"test"}'
    parsed = RustyJson.parse(json)
    rust = <<-RUST
struct Json {
    name: String,
}
      RUST
    expect(parsed).to eq(rust)
  end

  it 'removes bad key names' do
    json = '{"mutex-FileJournal::completions_lock": { "wait": { "avgcount": 0,"sum": 0.000000000}}}'

    rust = <<-RUST
struct JsonMutexFilejournalCompletionsLockWait {
    avgcount: i64,
    sum: f64,
}

struct JsonMutexFilejournalCompletionsLock {
    wait: JsonMutexFilejournalCompletionsLockWait,
}

struct Json {
    mutex_FileJournal_completions_lock: JsonMutexFilejournalCompletionsLock,
}
    RUST
    expect(RustyJson.parse(json)).to eq(rust)
  end

  context 'with an array' do
    it 'handles arrays of strings' do
      json = '{"age":33,"name":"Luc","hobbies":["fishing"]}'
      rust = <<-RUST
struct Json {
    age: i64,
    name: String,
    hobbies: Vec<String>,
}
      RUST
      expect(RustyJson.parse(json)).to eq(rust)
    end
    it 'handles an array of structs' do
      json = '{
        "users": [
          {
            "id": 1,
            "name": "Lauren"
          }
        ]
      }'

      rust = <<-RUST
struct JsonUser {
    id: i64,
    name: String,
}

struct Json {
    users: Vec<JsonUser>,
}
      RUST

      expect(RustyJson.parse(json)).to eq(rust)
    end
  end
  it 'can print the struct twice' do
    json = '{"name":"test"}'
    rust = <<-RUST
struct Json {
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
struct JsonTest {
    value: String,
}

struct Json {
    test: JsonTest,
}
    RUST
    expect(parsed).to eq(rust)
  end

  it 'parses arrays' do
    json = '{"key":[1,2,3]}'
    parsed = RustyJson.parse(json)

    rust = <<-RUST
struct Json {
    key: Vec<i64>,
}
    RUST
    expect(parsed).to eq(rust)
  end

  it 'parses integers' do
    json = '{"test":64}'
    parsed = RustyJson.parse(json)

    rust = <<-RUST
struct Json {
    test: i64,
}
    RUST
    expect(parsed).to eq(rust)
  end


  it 'can handle a recursive reference' do
    json = '{"key": {"key": {"key": {"key": 12}}}}'
    parsed = RustyJson.parse(json)
    rust = <<-RUST
struct JsonKeyKeyKey {
    key: i64,
}

struct JsonKeyKey {
    key: JsonKeyKeyKey,
}

struct JsonKey {
    key: JsonKeyKey,
}

struct Json {
    key: JsonKey,
}
    RUST

    expect(parsed).to eq(rust)
  end
end
