# Yampla

Build index and each item pages from YAML data with a template engine. Liquid is used for the engine.

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

###Step2. Provide an index template and a book template.

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

You can access books array data via **items** variable(by default) in Liquid tags. Each book properties can be accessed by method call style(ex. item.title).

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

You can access each book data via **item** variable(by default) in Liquid tags.

###Step3. Write ruby code using yampla gem and run it.

(book\_build.rb)

    require "yampla"

    ya = Yampla::Build.new('books.yaml')
    ya.set_template(:index, 'index_template.html')
    ya.set_template(:items, 'book_template.html')

    puts ya.run(:index)
    puts ya.run(:items)

As a result, you will get index output as follows;

    <!DOCTYPE html>
    <html>
      <head>
        <meta http-equiv="Content-type" content="text/html; charset=utf-8">
        <title>Book List</title>
      </head>
      <body>
        <ol>
          
          <li id="b1"><a href="b1.html">book1</a></li>
          
          <li id="b2"><a href="b2.html">book2</a></li>
          
          <li id="b3"><a href="b3.html">book3</a></li>
          
        </ol>
      </body>
    </html>

And get items output as hash like follows;

    {"b1"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\">\n    <title>book1</title>\n  </head>\n  <body>\n    <h2>book1</h2>\n    <p>1000JPY</p>\n    <p>2013-01-01</p>\n    <div>\n      \n      <small>ruby</small>\n      \n      <small>beginner</small>\n      \n    </div>\n  </body>\n</html>\n",
     "b2"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\">\n    <title>book2</title>\n  </head>\n  <body>\n    <h2>book2</h2>\n    <p>1500JPY</p>\n    <p>2013-02-07</p>\n    <div>\n      \n      <small>rails</small>\n      \n    </div>\n  </body>\n</html>\n",
     "b3"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-type\" content=\"text/html; charset=utf-8\">\n    <title>book3</title>\n  </head>\n  <body>\n    <h2>book3</h2>\n    <p>2400JPY</p>\n    <p>2013-03-15</p>\n    <div>\n      \n      <small>sinatra</small>\n      \n      <small>rack</small>\n      \n    </div>\n  </body>\n</html>\n"}


To get these results as files, try #save.

    ya.save(:index)
    ya.save(:items)

'index.html', 'b1.html', 'b2.html' and 'b3.html' with above contents will be created.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
