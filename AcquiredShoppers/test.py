from datetime import datetime

loc_offers = "offers.csv"


def reduce_data(loc_offers):

  start = datetime.now()
  #get all categories on offer in a dict
  offers = {}
  for e, line in enumerate( open(loc_offers) ):
    offers[ line.split(",")[1] ] = 1
  print "Amir"
  print len(offers)

reduce_data(loc_offers)