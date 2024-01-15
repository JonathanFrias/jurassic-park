# Jurrasic Park Management System

This project manages the dinosaurs in the park. It allows the user to add, remove, and view dinosaurs and their cages, and put manage them via cages. This is done via a RESTful api that is documented with swagger.


## Getting Started

Make sure you have ruby 3+ installed. Then clone the repo and run `bundle install` to install the dependencies.

Run `rails db:setup db:migrate` to setup the database. 

Review the token at `db/seeds.rb`, then run `rails db:seed`. This will seed a single user with an api-key `1234567890` by default.

Run `rails rswag:specs:swaggerize` to generate the interactive developer documentation. You can then view the documentation at `/api-docs`. These docs follow the swagger specification, and can be used to quickly test the api. It should look something like this:

![Swagger UI](https://uc1c24429e6b105b2f17f8ae8be5.previews.dropboxusercontent.com/p/thumb/ACITCAILqnSs1oH58WltETwemOSJHF69vS8m8C_UTjDFsv5yMtICykPm3CH9h5KnOHdrdMA6vryhajQE9ktECJdjAuHec1iwc0R1LUCE_daQeFRhqo8cnabcRQ9ESgR5XRLB5F0MuFlwUaKU4CM3CMkl3T_MRKG6q8kiP7Vg9Csi218dp4CC-F_7VpsACz8L9tzG_k7H1Q_lCvzoClsKvCuT3qYq_3HdXZKmuhKXHjLwTxf-noLft0iKf6MqbuYNDmH5u34MyDDNpkkixcbbrrPWW_TiRP-0DSvzQ5b2yiK0Svu8V_uW1RwO7fIX5K7-qXq4VvxKcKaplS27lw9nfRAk1oYVno_9hUSyIFaJ3YNccw/p.png)

Click the Authorize button and enter your api-key (default: `1234567890`)

Run `rails server` to start the server and visit `/api-docs` ([link↗](http://localhost:3000/api-docs))

## Testing

You can run spec examples using the `rspec` command.


## Design Decisions

The general approach for this project is to keep it as simple as possible, so I stayed aligned with Rails' defaults like sqlite3, and to allow it to be reviewed more easily. This project does not use any database-specific features so it can be trvially migrated. This project makes use of Rails features, so it's pretty tied to Rails. While it's possible that may not always be desirable the alternative is unforeseeable.

### Swagger docs

For quickly setting up an api that you can share with fellow developers and allow them to quickly play around with, I think this is an excellent choice. There are some plugins that can take swagger docs as input and generate rich clients for every popular language. This means that you have excellent developer docs that are up to date, and you have a nice integration plan for other vendors even if they don't write Ruby.

### Validations

For validations, ActiveRecord validations were used handle the data validation. This is preferable for smaller apps like these where super complex validation is not required.

For api development, getting the most value out of your tests is paramount. For this reason I decided to use the fantasic `rswag` gem, which allows you to perform basic tests of your api as well as provide developer-friendly documentation for yourself and other consumers. They also have the ability to generate clients in other languages for third party integrating customers.

I created fully documented CRUD (Create, Read, Update, Delete) operations for both cages as well as dinosaurs.

CRUD for users still needs to be done, as the dinosaurs keep eating the researchers, thus raising life insurance premiums.

I followed normal rails conventions, and there is room to make the controllers more DRY, however I decided that the complexity added would not be a worthwhile trade-off until there are more feature requests. 

### Presenters

I went with presenters for showing data, which I think is by far the most interesting part of this codebase. When you create a presenter, method calls should return other presenters and should **NOT** leak AR objects out. This is a problem that I see when most code that uses presenters. It's not immediately obvious how to use presenters in a way that retains the flexibility that you get from activerecord. For example, how do you present eager loaded associations, or nested activerecord queries, without directly dealing with the AR objects? You can solve this with a simple construct:

```ruby
class CagePresenter < SimpleDelegator
  def dinosaurs # overrides AR relation
    if block_given?
      DinosaurPresenter.from_collection(yield _cage.dinosaurs)
    else
      DinosaurPresenter.from_collection(_cage.dinosaurs)
    end
  end

  def _cage =  __getobj__

  def carnivores # overrides AR scope
    if _cage.dinosaurs.loaded?
      dinosaurs.select { |dinosaur| dinosaur.diet == "carnivore" }
    else
      dinosaurs { |query| query.where(diet: "carnivore") }
    end
  end
end
```

As you can imagine, `dinosaurs` here is overriding the underlying AR relation, such that when you call `cage.dinosaurs` you get back a collection of `DinosaurPresenter`s. However, because this method accepts a block, you can configure the underlying AR query with whatever you want right before the presenters get created, and still get back normal presenter objects, like so: `cage_presenter.dinosaurs { |query| query.where(diet: 'carnivore') } #=> DinosaurPresenters of carnivores`. Finally, because the block approach will always execute another query you can easily end up with an N+1 problem, which is common in ActiveRecord. For that reason we can override our AR scopes as well, and have the presenter intelligently check to see if the underlying association has been eager loaded, with reletively minimal increase in complexity.

There is a drawback to this approach, since it means that you may have to implement 2 versions of a scope in order for it to be efficient. This is a trade off I would accept because the awesome code locality (relevant code is nearby), as well the ability to define a clear and flexible pattern for efficient data loading.

"I think this style makes the presenter a monad, but don't quote me on that" - Jonathan


### Scale

Since most of the validation code happens in ruby code, there may be potential concurrency issues. In the future, we would need to test that changes that are made are either:

1. Fully wrapped in a transaction
2. Versioned (such that if you try to save a record and you don't have the latest version the write will raise)

### Database

I prefer the awesome Postgresql, howerver since I did not need any postgresql-specific features to complete this project I kept using sqlite. Keeping things easier to install for my readers is more important than using a database that I don't need.
