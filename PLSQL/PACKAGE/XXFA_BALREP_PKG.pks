--------------------------------------------------------
--  DDL for Package XXFA_BALREP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXFA_BALREP_PKG" AUTHID CURRENT_USER AS
   /*$Header: fabalreps.pls 120.7 2011/01/14 14:14:38 skchawla noship $*/
   PROCEDURE LOAD_WORKERS (
                           p_book_type_code   IN            VARCHAR2,
                           p_request_id       IN            NUMBER --,batch_size         in  number\
                                                                  ,
                           p_errbuf              OUT NOCOPY VARCHAR2,
                           p_retcode             OUT NOCOPY NUMBER
                          );

   PROCEDURE populate_gt_table (
      errbuf                     IN OUT NOCOPY VARCHAR2,
      retcode                    IN OUT NOCOPY VARCHAR2,
      Book                       IN            VARCHAR2,
      Report_Type                IN            VARCHAR2,
      Report_Style               IN            VARCHAR2,
      Request_id                 IN            NUMBER,
      Worker_number              IN            NUMBER,
      Period1_PC                 IN            NUMBER,
      Period1_POD                IN            DATE,
      Period1_PCD                IN            DATE,
      Period2_PC                 IN            NUMBER,
      Period2_PCD                IN            DATE,
      Distribution_Source_Book   IN            VARCHAR2);

   PROCEDURE LAUNCH_WORKERS (
      Book                       IN            VARCHAR2,
      Report_Type                IN            VARCHAR2,
      report_style               IN            VARCHAR2,
      l_Request_id               IN            NUMBER,
      Period1_PC                 IN            NUMBER,
      Period1_POD                IN            DATE,
      Period1_PCD                IN            DATE,
      Period2_PC                 IN            NUMBER,
      Period2_PCD                IN            DATE,
      Distribution_Source_Book   IN            VARCHAR2,
      p_total_requests1          IN            NUMBER,
      l_errbuf                      OUT NOCOPY VARCHAR2,
      l_retcode                     OUT NOCOPY NUMBER);
END XXFA_BALREP_PKG;

/
