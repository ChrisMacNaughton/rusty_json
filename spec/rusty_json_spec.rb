require 'spec_helper'

describe RustyJson do
  it 'has a version number' do
    expect(RustyJson::VERSION).not_to be nil
  end

  it 'parses json' do
    json = '{"name":"test"}'
    parsed = RustyJson.parse(json)
    rust = <<-RUST
pub struct Json {
    pub name: String,
}
      RUST
    expect(parsed).to eq(rust)
  end

  it 'removes bad key names' do
    json = '{"mutex-FileJournal::completions_lock": { "wait": { "avgcount": 0,"sum": 0.000000000}}}'

    rust = <<-RUST
pub struct JsonMutexFilejournalCompletionsLockWait {
    pub avgcount: i64,
    pub sum: f64,
}

pub struct JsonMutexFilejournalCompletionsLock {
    pub wait: JsonMutexFilejournalCompletionsLockWait,
}

pub struct Json {
    pub mutex_FileJournal_completions_lock: JsonMutexFilejournalCompletionsLock,
}
    RUST
    expect(RustyJson.parse(json)).to eq(rust)
  end

  it 'matches duplicate syntax' do
    json = '{
  "data1":
  {
    "name": "key",
    "val": 1
  },
  "data2": {
    "name": "key",
    "val": 2
  }
}'

    rust = <<-RUST
pub struct JsonData1 {
    pub name: String,
    pub val: i64,
}

pub struct Json {
    pub data1: JsonData1,
    pub data2: JsonData1,
}
    RUST
    expect(RustyJson.parse(json)).to eq(rust)
  end

  context 'with an array' do
    it 'handles arrays of strings' do
      json = '{"age":33,"name":"Luc","hobbies":["fishing"]}'
      rust = <<-RUST
pub struct Json {
    pub age: i64,
    pub name: String,
    pub hobbies: Vec<String>,
}
      RUST
      expect(RustyJson.parse(json)).to eq(rust)
    end
    it 'handles an array of pub structs' do
      json = '{
        "users": [
          {
            "id": 1,
            "name": "Lauren"
          }
        ]
      }'

      rust = <<-RUST
pub struct JsonUser {
    pub id: i64,
    pub name: String,
}

pub struct Json {
    pub users: Vec<JsonUser>,
}
      RUST

      expect(RustyJson.parse(json)).to eq(rust)
    end
  end
  it 'can print the pub struct twice' do
    json = '{"name":"test"}'
    rust = <<-RUST
pub struct Json {
    pub name: String,
}
      RUST
    expect(RustyJson.parse(json)).to eq(rust)
    expect(RustyJson.parse(json)).to eq(rust)
  end

  it 'parses nested json' do
    json = '{"test":{"value":"string"}}'
    parsed = RustyJson.parse(json)

    rust = <<-RUST
pub struct JsonTest {
    pub value: String,
}

pub struct Json {
    pub test: JsonTest,
}
    RUST
    expect(parsed).to eq(rust)
  end

  it 'parses arrays' do
    json = '{"key":[1,2,3]}'
    parsed = RustyJson.parse(json)

    rust = <<-RUST
pub struct Json {
    pub key: Vec<i64>,
}
    RUST
    expect(parsed).to eq(rust)
  end

  it 'parses integers' do
    json = '{"test":64}'
    parsed = RustyJson.parse(json)

    rust = <<-RUST
pub struct Json {
    pub test: i64,
}
    RUST
    expect(parsed).to eq(rust)
  end


  it 'can handle a recursive reference' do
    json = '{"key": {"key": {"key": {"key": 12}}}}'
    parsed = RustyJson.parse(json)
    rust = <<-RUST
pub struct JsonKeyKeyKey {
    pub key: i64,
}

pub struct JsonKeyKey {
    pub key: JsonKeyKeyKey,
}

pub struct JsonKey {
    pub key: JsonKeyKey,
}

pub struct Json {
    pub key: JsonKey,
}
    RUST

    expect(parsed).to eq(rust)
  end
end
