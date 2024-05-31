{{ config(materialized='table') }}

SELECT t.account_id_hashed as AccountID
, u.user_id_hashed as UserID
, t.date as TransactionDate
, a.CreationDate
, a.ClosureDate
, a.ReopeningDate
FROM
    {{ref('account_transactions')}} t
INNER JOIN {{ref('dim_users')}} u
ON t.account_id_hashed = u.account_id_hashed
INNER JOIN {{ref('dim_account')}} a 
ON t.account_id_hashed = a.AccountID
WHERE 
(lower(a.CurrentStatus) <> 'reopened' AND
t.date BETWEEN a.CreationDate AND COALESCE(a.ClosureDate, DATE('9999-12-31')))
OR 
(lower(a.CurrentStatus) = 'reopened' AND
(t.date BETWEEN a.CreationDate AND a.ClosureDate))
OR 
(lower(a.CurrentStatus) = 'reopened' AND
t.date BETWEEN a.ReopeningDate AND DATE('9999-12-31'))