require "yampla"

ya = Yampla::Build.new('books.yaml')
ya.set_template(:index, 'index_template.html')
ya.set_template(:items, 'item_template.html')

#puts ya.run(:index)
#puts ya.run(:items)
ya.save(:index)
ya.save(:items)
