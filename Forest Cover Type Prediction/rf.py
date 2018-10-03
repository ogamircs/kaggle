import pandas as pd
from sklearn import ensemble

if __name__ == "__main__":
  print "Reading stuff ..."
  loc_train = "train.csv"
  loc_test = "test.csv"
  loc_submission = "kaggle.forest.submission.csv"

  df_train = pd.read_csv(loc_train)
  df_test = pd.read_csv(loc_test)

  feature_cols = [col for col in df_train.columns if col not in ['Cover_Type','Id']]

  X_train = df_train[feature_cols]
  X_test = df_test[feature_cols]
  y = df_train['Cover_Type']
  test_ids = df_test['Id']
  
  print "Running stuff ..."
  #clf = ensemble.RandomForestClassifier(n_estimators = 1000, n_jobs = -1,verbose = 1)
  #clf = ensemble.GradientBoostingClassifier(n_estimators = 1000, verbose = 1)
  clf = ensemble.ExtraTreesClassifier(n_estimators = 100000, n_jobs = -1,verbose = 1)    

  clf.fit(X_train, y)
    
  print "Writing stuff ..."
  with open(loc_submission, "wb") as outfile:
    outfile.write("Id,Cover_Type\n")
    for e, val in enumerate(list(clf.predict(X_test))):
      outfile.write("%s,%s\n"%(test_ids[e],val))