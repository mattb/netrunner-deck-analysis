# Encoding: utf-8
require 'json'

cards = JSON.parse(open("cards.json").read)
decks = Dir.glob("2*.json").map { |f| JSON.parse(open(f).read) }.flatten

card_idx = {}
cards.each { |card|
  card["name"] = card["code"]
  card["label"] = card["title"]
  card.delete("code")
  card.delete("title")
  card["count"] = 0
  card_idx[card["name"]] = card
}

decks.each { |deck|
  deck['cards'].each { |card, count|
    card_idx[card]['count'] += count
  }
}

card = cards.first
keys = ["name", "label"] + (card.keys - ["name", "label"])
card_schema = keys.map { |k| k + " " + (card[k].is_a?(Numeric) ? "DOUBLE" : "VARCHAR") }
puts "nodedef>" + card_schema.join(",")
cards.each { |card|
  vals = keys.map { |k| 
    val = card[k]
    val.is_a?(Numeric) ? val.to_s : "'#{val.to_s.gsub(/(\n|\r|'|"|’)/," ")}'" 
  }
  puts vals.join(",")
}

co = {}
co.default = 0
decks.each { |deck|
  deck['cards'].each { |card_id, count|
    deck['cards'].each { |card2_id, count2|
      if card_id != card2_id
        key = [card_id, card2_id].sort
        co[key] += count + count2
      end
    }
  }
}

puts "edgedef>node1 VARCHAR, node2 VARCHAR, weight INT"
co.each { |k,v|
  puts "'#{k[0]}','#{k[1]}',#{v}"
}
