# Chen-Style Entity-Relationship Diagram

Here is the updated Entity-Relationship diagram designed with the classic Chen notation style (Entities as rectangles, Relationships as diamonds, Attributes as ovals, and Primary Keys underlined).

```mermaid
flowchart TD
    %% Entities
    U[User]
    I[Instructor]
    C[Course]
    V[Vehicle]
    B[Booking]
    TS[Time Slot]
    R[Rating]
    A[Attendance]
    TR[Mock Test Result]

    %% Relationships
    Enrolls{Enrolls In}
    Assigned{Assigned To}
    Makes{Makes}
    ForSlot{For Slot}
    Uses{Uses}
    Gives{Gives}
    Receives{Receives Rating}
    HasAtt{Has}
    Takes{Takes}

    %% Connections linking Entities through Relationships
    U --- Enrolls --- C
    U --- Assigned --- I
    U --- Makes --- B
    B --- ForSlot --- TS
    I --- Uses --- V
    U --- Gives --- R
    R --- Receives --- I
    U --- HasAtt --- A
    U --- Takes --- TR

    %% -------- Attributes --------
    
    %% User Attributes
    PK_U([<u>userID</u>])
    U_name([userName])
    U_email([userEmail])
    U --- PK_U
    U --- U_name
    U --- U_email

    %% Instructor Attributes
    PK_I([<u>instructorID</u>])
    I_name([instructorName])
    I_status([status])
    I --- PK_I
    I --- I_name
    I --- I_status

    %% Course Attributes
    PK_C([<u>courseID</u>])
    C_name([courseName])
    C_price([coursePrice])
    C --- PK_C
    C --- C_name
    C --- C_price

    %% Vehicle Attributes
    PK_V([<u>id</u>])
    V_plate([plateNumber])
    V_model([modelName])
    V --- PK_V
    V --- V_plate
    V --- V_model

    %% Booking Attributes
    PK_B([<u>bookingID</u>])
    B_date([date])
    B --- PK_B
    B --- B_date

    %% TimeSlot Attributes
    PK_TS([<u>slotID</u>])
    TS_start([startTime])
    TS_end([endTime])
    TS --- PK_TS
    TS --- TS_start
    TS --- TS_end

    %% Rating Attributes
    PK_R([<u>ratingID</u>])
    R_score([score])
    R_comment([comment])
    R --- PK_R
    R --- R_score
    R --- R_comment

    %% Attendance Attributes
    PK_A([<u>attID</u>])
    A_date([attDate])
    A --- PK_A
    A --- A_date

    %% Mock Test Result Attributes
    PK_TR([<u>testID</u>])
    TR_score([score])
    TR_weak([weakArea])
    TR --- PK_TR
    TR --- TR_score
    TR --- TR_weak

    %% Styling
    classDef entity fill:#d4e157,stroke:#33691e,stroke-width:2px;
    classDef relation fill:#bbdefb,stroke:#0d47a1,stroke-width:2px;
    classDef attribute fill:#ffe082,stroke:#ff6f00,stroke-width:1px;

    class U,I,C,V,B,TS,R,A,TR entity;
    class Enrolls,Assigned,Makes,ForSlot,Uses,Gives,Receives,HasAtt,Takes relation;
    class PK_U,U_name,U_email,PK_I,I_name,I_status,PK_C,C_name,C_price,PK_V,V_plate,V_model,PK_B,B_date,PK_TS,TS_start,TS_end,PK_R,R_score,R_comment,PK_A,A_date,PK_TR,TR_score,TR_weak attribute;
```
