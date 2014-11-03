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

idents = {}
cards.select { |c| c['type_code'] == 'identity' }.each { |c| idents[c['name']] = c['label'] }

focus_card_ids = card_idx.select { |k,card| card['label'] == ARGV[0] }.keys

decks_with_card = decks.select { |deck| deck['cards'].keys.any? { |cid| focus_card_ids.include?(cid) } }
ident_counts = {}
ident_counts.default = 0
decks_with_card.each { |deck|
  faction = (deck['cards'].keys & idents.keys).first
  count = deck['cards'].select { |id, count| focus_card_ids.include? id }.map { |id, count| count }.inject(0) { |a,b| a + b }
  ident_counts[idents[faction]] += count
}
divisor = 80.0 / ident_counts.map { |f, count| count }.sort.last
puts ident_counts.sort_by { |f, count| count }.map { |f, count| ("*" * (count * divisor)) + " #{f}" }.join("\n")
