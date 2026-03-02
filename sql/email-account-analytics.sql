-- =====================================================
-- 1. INFORMAÇÕES ÚNICAS POR CONTA -- =====================================================
WITH account_info AS (
  SELECT 
    acs.account_id,
    MIN(s.date) AS create_date,
    ARRAY_AGG(sp.country ORDER BY s.date ASC, s.ga_session_id ASC LIMIT 1)[OFFSET(0)] AS country
  FROM `data-analytics-mate.DA.account_session` acs
  JOIN `data-analytics-mate.DA.session` s ON acs.ga_session_id = s.ga_session_id
  JOIN `data-analytics-mate.DA.session_params` sp ON acs.ga_session_id = sp.ga_session_id
  GROUP BY acs.account_id
),

-- =====================================================
-- 2. MÉTRICAS DE CONTA
-- =====================================================
account_metrics AS (
  SELECT
    ai.create_date AS date,
    ai.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed,
    COUNT(DISTINCT a.id) AS account_cnt,
    0 AS sent_msg,
    0 AS open_msg,
    0 AS visit_msg
  FROM `data-analytics-mate.DA.account` a
  JOIN account_info ai ON a.id = ai.account_id
  GROUP BY 1, 2, 3, 4, 5
),

-- =====================================================
-- 3. MÉTRICAS DE EMAIL
-- =====================================================
email_metrics AS (
  SELECT
    DATE_ADD(ai.create_date, INTERVAL es.sent_date DAY) AS date,
    ai.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed,
    0 AS account_cnt,
    COUNT(DISTINCT es.id_message) AS sent_msg,
    COUNT(DISTINCT eo.id_message) AS open_msg,
    COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM `data-analytics-mate.DA.email_sent` es
  JOIN `data-analytics-mate.DA.account` a ON es.id_account = a.id
  JOIN account_info ai ON a.id = ai.account_id
  LEFT JOIN `data-analytics-mate.DA.email_open` eo ON es.id_message = eo.id_message
  LEFT JOIN `data-analytics-mate.DA.email_visit` ev ON es.id_message = ev.id_message
  GROUP BY 1, 2, 3, 4, 5
),

-- =====================================================
-- 4. UNIÃO DAS MÉTRICAS
-- =====================================================
union_data AS (
  SELECT * FROM account_metrics
  UNION ALL
  SELECT * FROM email_metrics
),

-- =====================================================
-- 5. CONSOLIDAÇÃO FINAL APÓS UNION
-- =====================================================
final_agg AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    SUM(account_cnt) AS account_cnt,
    SUM(sent_msg) AS sent_msg,
    SUM(open_msg) AS open_msg,
    SUM(visit_msg) AS visit_msg
  FROM union_data
  WHERE country IS NOT NULL
  GROUP BY 1, 2, 3, 4, 5
),

-- =====================================================
-- 6. TOTAIS POR PAÍS 
-- =====================================================
country_totals AS (
  SELECT
    *,
    SUM(account_cnt) OVER(PARTITION BY country) AS total_country_account_cnt,
    SUM(sent_msg) OVER(PARTITION BY country) AS total_country_sent_cnt
  FROM final_agg
),

-- =====================================================
-- 7. RANKING (DENSE_RANK SOBRE OS TOTAIS)
-- =====================================================
ranked_data AS (
  SELECT
    *,
    DENSE_RANK() OVER(ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
    DENSE_RANK() OVER(ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
  FROM country_totals
)

-- =====================================================
-- 8. RESULTADO FINAL
-- =====================================================
SELECT *
FROM ranked_data
WHERE rank_total_country_account_cnt <= 10 
   OR rank_total_country_sent_cnt <= 10
ORDER BY date;
