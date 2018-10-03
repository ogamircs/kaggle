public static double Auc(this IList a, IList p) {
    // AUC requires int array as dependent

    var all = a.Zip(p, (actual, pred) => new {actualValue = actual < 0.5 ? 0 : 1, predictedValue = pred}).OrderBy(ap => ap.predictedValue).ToArray();

    long n = all.Length;
    long ones = all.Sum(v => v.actualValue);
    if (0 == ones || n == ones) return 1;

    long tp0, tn;
    long truePos = tp0 = ones; long accum = tn = 0; double threshold = all[0].predictedValue;
    for (int i = 0; i < n; i++) {
        if (all[i].predictedValue != threshold) { // threshold changes
            threshold = all[i].predictedValue;
            accum += tn * (truePos + tp0); //2* the area of  trapezoid
            tp0 = truePos;
            tn = 0;
        }
        tn += 1 - all[i].actualValue; // x-distance between adjacent points
        truePos -= all[i].actualValue;
    }
    accum += tn * (truePos + tp0); // 2 * the area of trapezoid
    return (double)accum / (2 * ones * (n - ones));
}