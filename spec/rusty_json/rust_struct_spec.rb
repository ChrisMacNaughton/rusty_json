require 'spec_helper'
require 'pry'
describe RustyJson::RustStruct do
  it 'can build a Rust struct' do
    struct = RustyJson::RustStruct.new('JSON', true)

    struct.add_value('name', String)
    struct.add_value('types', Array, Fixnum)

    rust = <<-RUST
struct JSON {
    name: String,
    types: Vec<i64>,
}

    RUST

    expect(struct.to_s).to eq(rust)
  end

  it 'can be root' do
    struct = RustyJson::RustStruct.new('Json', true)
    expect(struct.root).to be_truthy
    struct.add_value('name', String)

    rust = <<-RUST
struct Json {
    name: String,
}

    RUST

    expect(struct.to_s).to eq(rust)
    expect(struct.to_s).to eq(rust)
  end

  it 'can reset' do
    struct = RustyJson::RustStruct.new('Json')
    expect(struct.root).to be_falsey
    struct.add_value('name', String)

    rust = <<-RUST
struct Json {
    name: String,
}

    RUST

    expect(struct.to_s).to eq(rust)
    expect(struct.to_s).to eq('')

    struct.reset

    expect(struct.to_s).to eq(rust)
  end

  it 'can be nested' do
    parent = RustyJson::RustStruct.new('Parent')
    parent.add_value('name', String)

    job = RustyJson::RustStruct.new('Job')
    job.add_value('name', String)
    job.add_value('start', Fixnum)
    job.add_value('end', Fixnum)

    person = RustyJson::RustStruct.new('Person', true)
    person.add_value('name', String)
    person.add_value('age', Fixnum)
    person.add_value('mother', parent)
    person.add_value('father', parent)
    person.add_value('jobs', Array, job)

    rust = <<-RUST
struct Parent {
    name: String,
}

struct Job {
    name: String,
    start: i64,
    end: i64,
}

struct Person {
    name: String,
    age: i64,
    mother: Parent,
    father: Parent,
    jobs: Vec<Job>,
}

    RUST
    expect(person.to_s).to eq(rust)
  end

end