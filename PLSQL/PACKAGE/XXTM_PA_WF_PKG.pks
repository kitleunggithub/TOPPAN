--------------------------------------------------------
--  DDL for Package XXTM_PA_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXTM_PA_WF_PKG" 
/* $Header: PAXTMPFS.pls 120.2 2005/08/08 12:41:11 sbharath noship $ */
/* Copied from pa_wf_fb_sample_pkg for Toppan Merrill 2021/03/28 */
AUTHID CURRENT_USER AS
 PROCEDURE xxtm_pa_wf_sql_fn
	(	p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT NOCOPY VARCHAR2);



END xxtm_pa_wf_pkg;

/
