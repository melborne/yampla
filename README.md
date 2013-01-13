# Yampla

Build List & Item pages from YAML data with a template engine. Liquid is used for the engine.

## Installation

Add this line to your application's Gemfile:

    gem 'yampla'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yampla

## Usage

A simple example to create a book index page and each book pages.

###Step1. Provide book data with YAML format.

(book.yaml)

    b1:
      title: book1
      price: 1000JPY
      date: 2013-1-1
      keywords:
        - ruby
        - beginner
    b2:
      title: book2
      price: 1500JPY
      date: 2013-2-7
      keywords:
        - rails
    b3:
      title: book3
      price: 2400JPY
      date: 2013-3-15
      keywords:
        - sinatra
        - rack

###Step2. Provide index template and book template.

(index\_template.html)

    <!DOCTYPE html>
    <html>
      <head>
        <meta http-equiv="Content-type" content="text/html; charset=utf-8">
        <title>Book List</title>
      </head>
      <body>
        <ol>
          {% for item in items %}
          <li id="{{ item.id }}"><a href="{{ item.id }}.html">{{ item.title }}</a></li>
          {% endfor %}
        </ol>
      </body>
    </html>

(book\_template.html)

    <!DOCTYPE html>
    <html>
      <head>
        <meta http-equiv="Content-type" content="text/html; charset=utf-8">
        <title>{{ item.title }}</title>
      </head>
      <body>
        <h2>{{ item.title }}</h2>
        <p>{{ item.price }}</p>
        <p>{{ item.date }}</p>
        <div>
          {% for key in item.keywords %}
          <small>{{ key }}</small>
          {% endfor %}
        </div>
      </body>
    </html>

###Step3. Write ruby code using yampla gem and run it.

(book\_build.rb)

    require "yampla"

    ya = Yampla::Build.new('books.yaml')
    ya.set_template(:index, 'index_template.html')
    ya.set_template(:items, 'book_template.html')

    ya.save(:index)
    ya.save(:items)

As result, 'index.html', 'b1.html', 'b2.html' and 'b3.html' are created.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
