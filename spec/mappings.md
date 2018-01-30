# Mapping Builder

Elasticsearch has a concept called `Mappings`. They're essentially data
definitions like you'd find in a SQL database, but applied in a NoSQL fashion.
The JSON below describe the mapping for a `type` within an `index`. Quick
Elasticsearch tutorial:

* An `Index` is essentially like a database: It stores data, and you can query
data from it.
* A `Type` is a sub structure of an `index`, very much like a table in a
database. Mappings are usually defined for each `property` of a `type` within an
`index`.

I need an interface with which the mappings for an `index` / `type` can be
built. The resulting data I need to get will need to look like this:

```
{
  ".marvel-es-1-2016.07.26" : {       # This is the name of the `index`
    "mappings" : {                    # We're dealing with the index's mappings
      "index_recovery" : {            # This is the name of the `type`
        "properties" : {              # The `properties` are essentially the fields of the `type`
          "cluster_uuid" : {          # The name of the field
            "type" : "string",        # The field is of type `string`
            "index" : "not_analyzed"  # It's "index" setting is set to not_anylzed
          }
        }
      }
    }
  }
}
```

Simple enough. As you can see each field, called a property, has a type, and can
also have other settings. Different types of properties have different settings
than can be applied.

The interface should have two dropdowns / text boxes: One for the index, one for
the type. I'll give you calls to fetch the existing indices and types. It should
allow for new indices and types as well. Please use Select2 or something
similiar for the dropdowns: https://select2.github.io/

Below the two dropdowns, the user should be able to define 1 or more properties.
The user should at a minimum specify the type for the property, and should have
the ability to specify 0 or more settings for the property.

The available settings should be filtered dependent on the type.

The setting values will mostly also be from a dropdown, once again filtered
depending on the setting name.

## Types

* string
* long
* integer
* short
* byte
* double
* float
* date
* boolean
* binary
* object
* nested
* geo_point
* geo_shape
* ip
* completion
* token_count
* murmur3

## Settings

By default allow the user to set all the settings for a property.

By default allow the user to define the value for the setting using a text box.

These are the available settings:

* analyzer
* boost
* coerce
* copy_to
* doc_values
* dynamic
* enabled
* fielddata
* format
* geohash
* geohash_precision
* geohash_prefix
* ignore_above
* ignore_malformed
* include_in_all
* index
* index_options
* lat_lon
* fields
* norms
* null_value
* position_increment_gap
* precision_step
* properties
* search_analyzer
* similarity
* store
* term_vector

### Type Restrictions

For the following types, the following restrictions apply:

#### All types

All of the types can have the following settings:

* enabled
* store
* include_in_all

#### `date`

The `date` field can have the following additional settings:

* format

### Setting Restrictions

For the following settings, the following restrictions apply:

* **index**: One of `no`, `not_analyzed`, `analyzed`
* **boost**: A decimal number with a maximum of three digits after the .
* **doc_values**: A boolean, `true` or `false`. Display as `Yes` or `No`
* **enabled**: A boolean, `true` or `false`. Display as `Yes` or `No`
* **store**:  A boolean, `true` or `false`. Display as `Yes` or `No`
* **ignore_above**: A positive integer
* **ignore_malformed**:  A boolean, `true` or `false`. Display as `Yes` or `No`
* **include_in_all**:  A boolean, `true` or `false`. Display as `Yes` or `No`.
Cannot be set when `index` is `no`.
* **properties**: See ``Nested Mappings` below`. Only available for properties of type `object`.
* **fields**: See `Nested Mappings` below.

## Nested Mappings

The `fields` and  `properties` settings contain mappings following all the rules
set out here, and can be nested to the nth degree.

```
{
  ".marvel-es-1-2016.07.26" : {
    "mappings" : {
      "index_recovery" : {
        "type": "object",
        "properties" : {                 # The `types` properties
          "source_node" : {              # The top mapping
            "properties" : {             # The nested properties
              "attributes" : {           # The nested field (source_node.attributes)
                "dynamic" : "true",      # A setting for this mapping
                "properties" : {         # More nested properties
                  "client" : {           # The nested field (source_node.attribute.client)
                    "type" : "boolean"   # The nested field's type
                  },
                  "data" : {
                    "type" : "boolean"
                  },
                  "master" : {
                    "type" : "boolean"
                  }
                }
              }
            }
          }
        }
      },
      "status": {
        "type": "string",
        "fields": {
          "raw": { 
            "type":"string",
            "index": "not_analyzed"
          }
        }
      }
    }
  }
}
```

More reading on mappings: https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html