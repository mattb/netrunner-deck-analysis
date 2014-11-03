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

puts "RUNNER"
cards.sort_by { |c| c['count'] }.select { |c| c['side_code'] == 'runner' }.group_by { |c| c['setname'] }.map { |set, cards| [set, cards.map { |c| c['count'] }] }.map { |set, counts| [set, counts.inject(0) { |a,b| a + b }] }.sort_by { |set, count| count }.each { |label, count| puts ["*" * (count/350), label].join(" ") }

puts "---"
puts "CORP"
cards.sort_by { |c| c['count'] }.select { |c| c['side_code'] == 'corp' }.group_by { |c| c['setname'] }.map { |set, cards| [set, cards.map { |c| c['count'] }] }.map { |set, counts| [set, counts.inject(0) { |a,b| a + b }] }.sort_by { |set, count| count }.each { |label, count| puts ["*" * (count/350), label].join(" ") }
