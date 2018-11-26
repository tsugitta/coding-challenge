SELECT
    Score,
    (
        SELECT
            count(distinct score) + 1
  	   	FROM
            Scores scores_2
  	   	WHERE
            scores_2.score > scores_1.score
    ) as Rank
FROM
    scores scores_1
ORDER BY
    Rank;
