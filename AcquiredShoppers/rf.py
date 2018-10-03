import pandas as pd
from sklearn import ensemble

if __name__ == "__main__":
  loc_train = "fullTrainM4.csv"
  #loc_test = "fullTestM4.csv"
  loc_test = "fullTrainM4.csv"
  #loc_submission = "kaggle.forest.submission.csv"
  loc_submission = "trainScore.csv"    

  df_train = pd.read_csv(loc_train)
  df_test = pd.read_csv(loc_test)

  feature_cols = [col for col in df_train.columns if col not in ['repeater','id']]

  X_train = df_train[feature_cols]
  X_test = df_test[feature_cols]
  y = df_train['repeater']
  #test_ids = df_test['id']
  test_ids = df_test['id']   
  print "running RF ..."
  clf = ensemble.RandomForestClassifier(n_estimators = 500, n_jobs = -1)

  clf.fit(X_train, y)
  print "scoring ..."
  with open(loc_submission, "wb") as outfile:
    outfile.write("id,repeatProbability\n")
    for e, val in enumerate(list(clf.predict_proba(X_test))):
      outfile.write("%s,%s\n"%(test_ids[e],val[1]))