Use parkingcitationsdb;

-- Visitor registration form (Outlook equivalent)
CREATE TABLE Visitor_Reg (
    VisitorRegID        INT AUTO_INCREMENT PRIMARY KEY,
    LicensePlateNumber  VARCHAR(15) NOT NULL,
    VisitDate           DATE NOT NULL,
    FirstName           VARCHAR(100),
    LastName            VARCHAR(100),
    Street              VARCHAR(255),
    ZipCode             VARCHAR(10),
    Email               VARCHAR(100),
    Purpose             VARCHAR(100),
    BuildingToVisit     VARCHAR(100)
);

-- Citation change log table ... tracks changes to citations
CREATE TABLE Citation_Change_Log (
    LogID          INT AUTO_INCREMENT PRIMARY KEY,
    CitationID     VARCHAR(50) NOT NULL,
    ChangeType     VARCHAR(20) NOT NULL,   -- 'INSERT', 'UPDATE'
    OldPlate       VARCHAR(15),
    NewPlate       VARCHAR(15),
    OldConsumerID  INT,
    NewConsumerID  INT,
    ChangeTime     DATETIME NOT NULL,
    ChangedBy      VARCHAR(50)
);


-- Match visitor form to citation by plate + date (performance index)
CREATE INDEX idx_visitor_plate_date
  ON Visitor_Reg(LicensePlateNumber, VisitDate);

-- Index + FK on citation ID in the log
ALTER TABLE Citation_Change_Log
  ADD INDEX idx_citation_log_citation (CitationID),
  ADD CONSTRAINT fk_citation_log_citation
    FOREIGN KEY (CitationID) REFERENCES T2_Citation(CitationID);

-- Trigger on T2_Citation: After INSERT trigger (new citation logged)
DELIMITER //

CREATE TRIGGER trg_citation_insert_log
AFTER INSERT ON T2_Citation
FOR EACH ROW
BEGIN
    INSERT INTO Citation_Change_Log (
        CitationID, ChangeType,
        OldPlate, NewPlate,
        OldConsumerID, NewConsumerID,
        ChangeTime, ChangedBy
    )
    VALUES (
        NEW.CitationID, 'INSERT',
        NULL, NEW.LicensePlateNumber,
        NULL, NEW.ConsumerID,
        NOW(), 'SYSTEM'
    );
END//

DELIMITER ;

-- After UPDATE trigger (manual review / corrections)
-- After UPDATE trigger (manual review / corrections)
Delimiter // 
CREATE TRIGGER trg_citation_update_log
AFTER UPDATE ON T2_Citation
FOR EACH ROW
BEGIN
    IF OLD.LicensePlateNumber <> NEW.LicensePlateNumber
       OR OLD.ConsumerID <> NEW.ConsumerID
       Or OLD.Violation <> NEW.Violation
       THEN
        INSERT INTO Citation_Change_Log (
            CitationID, ChangeType,
            OldPlate, NewPlate,
            OldConsumerID, NewConsumerID,
            ChangeTime, ChangedBy
        )
        VALUES (
            NEW.CitationID, 'UPDATE',
            OLD.LicensePlateNumber, NEW.LicensePlateNumber,
            OLD.ConsumerID, NEW.ConsumerID,
            NOW(), 'STAFF'
        );
    END IF;
END//

DELIMITER ;

Update T2_Citation
set Violation = 2
Where CitationID = '26D200200004';
#---------------------------------
UPDATE T2_Citation
SET Violation = 3
WHERE CitationID = '26D200200034';

UPDATE T2_Citation
SET Violation = 3
WHERE CitationID = '26D200200083';

UPDATE T2_Citation
SET Violation = 4
WHERE CitationID = '26D200200085';

UPDATE T2_Citation
SET Violation = 4
WHERE CitationID = '26D200200090';

UPDATE T2_Citation
SET Violation = 2
WHERE CitationID = '26D200200102';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200120';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200131';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200144';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200163';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200164';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200182';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200183';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200210';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200217';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200247';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200251';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200277';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200309';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200312';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200323';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200325';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200326';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200332';

UPDATE T2_Citation
SET Violation = 1
WHERE CitationID = '26D200200345';



select * from Citation_Change_Log;
select * from t2_citation;
describe t2_citation;

-- STORED PROCEDURE

DELIMITER //
CREATE PROCEDURE Mistake_Rate_IssueID (
	IN IssuerID VARCHAR(10)
    )
BEGIN
    SELECT
  (COUNT(DISTINCT l.CitationID)
   / COUNT(DISTINCT c.CitationID)
  ) * 100 AS pct_mistake
FROM T2_Citation as c
LEFT JOIN Citation_Change_Log as l
  ON c.CitationID = l.CitationID
WHERE IssuerID = c.IssuerID AND l.ChangeType = 'UPDATE';
END //
DELIMITER ;
CALL Mistake_Rate_IssueID('PO87');

-- ======================
-- Metrics
-- ======================

-- 1) Avg processing time (Issue -> first manual review)

SELECT 
    AVG(
      TIMESTAMPDIFF(
        DAY,
        c.IssueDate,
        l.ChangeTime
      )
    ) AS avg_processing_time_days
FROM T2_Citation as c
JOIN (
    SELECT CitationID, MIN(ChangeTime) AS ChangeTime
    FROM Citation_Change_Log
    WHERE ChangeType = 'UPDATE'
    GROUP BY CitationID
) l
  ON c.CitationID = l.CitationID;

-- 2) % of citations that required manual review
SELECT
  (COUNT(DISTINCT l.CitationID) * 1.0
   / COUNT(DISTINCT c.CitationID)
  ) * 100 AS pct_manual_reviews
FROM T2_Citation as c
LEFT JOIN Citation_Change_Log as l
  ON c.CitationID = l.CitationID
 AND l.ChangeType = 'UPDATE';

-- 3) Repeat offender rate (plates with multiple citations)
SELECT 
  (COUNT(*) * 1.0
   / (SELECT COUNT(DISTINCT LicensePlateNumber)
      FROM T2_Citation)
  ) * 100 AS repeat_offender_rate_pct
FROM (
    SELECT LicensePlateNumber
    FROM T2_Citation
    GROUP BY LicensePlateNumber
    HAVING COUNT(*) > 1
) AS t;



#KPI 1: Average Processing Time
Create View v_processing_time as
Select
c.CitationID,
c.IssueDate,
c.IssuerID,
c.Violation,
c.AmountDue,
Case
When
Timestampdiff(Day, c.IssueDate, Min(l.ChangeTime)) < 0 Then NULL
Else Timestampdiff(Day, c.IssueDate, Min(l.ChangeTime))
End as ProcessingTime
From
T2_Citation as c
Join
Citation_Change_Log as l
On
l.CitationID=c.CitationID
Where l.ChangeType='Update'
Group by CitationID;


#KPI 2: Percent of Mistakes
Create View v_manual_review as
Select
Count(Distinct c.CitationID) as TotalCitations,
Count(Distinct l.CitationID) as ManualCount,
(Count(Distinct l.CitationID)/Count(Distinct c.CitationID)) * 100 as Percentage
From
T2_Citation as C
Left Join
Citation_Change_Log as l
On
c.CitationID = l.CitationID
And l.ChangeType = 'UPDATE'
;



#KPI 3: Repeat Offender Rate Percentage

Create  or replace View v_repeat_offender AS
Select
LicensePlateNumber,
Count(*) as citation_count,
Case
When Count(*) > 1 Then "Repeat"
Else "Non-Repeat"
End as Status
From
T2_Citation
Group by
LicensePlateNumber;


# View 4 - Assists in creating Repeat Offender Percentage
Create View v_repeat_offender_rate as
Select
(Sum(Case When Status = "Repeat" then 1 else 0 End) * 100 /
Count(*)) As RepeatOffenderRate
From
v_repeat_offender;
