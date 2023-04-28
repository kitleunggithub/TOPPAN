--------------------------------------------------------
--  DDL for Package XXPA_PROJECT_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXPA_PROJECT_WEBADI_PKG" 
IS
/************************************************************************
 * Package:     XXPA_PROJECT_WEBADI_PKG
 *
 * MODIFICATION HISTORY:
 * ver Name           Date          Description
 * === =============  ============  =====================================
 * 1.0 Kit Leung      2020-12-14    Created
 *
 ************************************************************************/

  PROCEDURE import_data(p_run_id            IN NUMBER/*,
                        x_msg               OUT NOCOPY VARCHAR,
                        x_request_id        OUT NOCOPY NUMBER*/ );

END XXPA_PROJECT_WEBADI_PKG;


/
