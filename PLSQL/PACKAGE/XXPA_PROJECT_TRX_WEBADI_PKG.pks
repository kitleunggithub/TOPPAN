--------------------------------------------------------
--  DDL for Package XXPA_PROJECT_TRX_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXPA_PROJECT_TRX_WEBADI_PKG" as
/************************************************************************
 * Package:     XXPA_PROJECT_TRX_WEBADI_PKG
 *
 * MODIFICATION HISTORY:
 * ver Name           Date          Description
 * === =============  ============  =====================================
 * 1.0 Kit Leung      2020-12-14    Created
 *
 ************************************************************************/

Procedure Trx_Import ( P_Transaction_Source IN VARCHAR2,
                       P_Batch_Name         IN VARCHAR2,
                       P_Org_Id             IN NUMBER,
                       X_Msg               OUT NOCOPY VARCHAR,
                       X_Request_Id        OUT NOCOPY NUMBER );

End XXPA_PROJECT_TRX_WEBADI_PKG;


/
