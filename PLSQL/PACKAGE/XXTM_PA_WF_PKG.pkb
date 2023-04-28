--------------------------------------------------------
--  DDL for Package Body XXTM_PA_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXTM_PA_WF_PKG" 
/* $Header: PAXTMPFB.pls 120.3.12020000.2 2015/07/31 06:18:52 navemish ship $ */
/* Copied from pa_wf_fb_sample_pkg for Toppan Merrill 2021/03/28 */
 AS

 PROCEDURE xxtm_pa_wf_sql_fn
	(	p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT NOCOPY VARCHAR2)
AS

l_project_number	pa_projects_all.segment1%TYPE;
l_expenditure_org_id	hr_organization_units.organization_id%TYPE;
l_project_org_id	hr_organization_units.organization_id%TYPE;
l_expenditure_type	pa_expenditure_types.expenditure_type%TYPE;
l_org_id        hr_organization_units.organization_id%TYPE;
l_segment_value_pl		gl_code_combinations.segment2%TYPE;
l_segment_value_cc		gl_code_combinations.segment4%TYPE;
l_segment_value_le		gl_code_combinations.segment1%TYPE;

BEGIN

  l_project_number	:= wf_engine.GetItemAttrText
			( itemtype => p_itemtype,
			  itemkey  => p_itemkey,
			  aname	   => 'PROJECT_NUMBER');

  l_expenditure_type	:= wf_engine.GetItemAttrText
			( itemtype => p_itemtype,
			  itemkey  => p_itemkey,
			  aname	   => 'EXPENDITURE_TYPE');

  l_org_id	:= wf_engine.GetItemAttrNumber
			( itemtype => p_itemtype,
			  itemkey  => p_itemkey,
			  aname	   => 'ORG_ID');

---------------------------------------------------
-- Now start determining the value of the segment
---------------------------------------------------


  BEGIN

	SELECT glc.segment2
    INTO l_segment_value_pl
	FROM pa_projects_all p, ar_memo_lines_all_b m,
	gl_code_combinations glc
	WHERE p.attribute1 = m.memo_line_id
	AND m.gl_id_rev = glc.code_combination_id
	AND p.segment1 =  l_project_number;

  EXCEPTION

    WHEN no_data_found
    THEN


        wf_core.context( pkg_name	=> 'xxtm_pa_wf_pkg',
			 proc_name	=> 'xxtm_pa_wf_sql_fn',
			 arg1		=>  l_project_number,
			 arg2		=>  l_expenditure_type,
			 arg3		=>  l_expenditure_org_id,
			 arg4		=>  l_expenditure_type,
			 arg5		=>  null);



      wf_engine.SetItemAttrText
		( itemtype=> p_itemtype,
		  itemkey => p_itemkey,
		  aname	  => 'ERROR_MSG',
		  avalue  => 'Product Line Lookup Failed');



	x_result := 'COMPLETE:FAILURE';
	RETURN;
  END;

  BEGIN

    SELECT  segment_value
    INTO  l_segment_value_le
    FROM  pa_segment_value_lookups 	valuex,
          pa_segment_value_lookup_sets 	sets
    WHERE  sets.segment_value_lookup_set_id   =  valuex.segment_value_lookup_set_id
    AND  sets.segment_value_lookup_set_name = 'LE-OPERATING UNIT'
    AND  valuex.segment_value_lookup 	    = (select name from hr_organization_units where organization_id = l_org_id);


  EXCEPTION

    WHEN no_data_found
    THEN


        wf_core.context( pkg_name	=> 'xxtm_pa_wf_pkg',
			 proc_name	=> 'xxtm_pa_wf_sql_fn',
			 arg1		=>  l_project_number,
			 arg2		=>  l_expenditure_type,
			 arg3		=>  l_expenditure_org_id,
			 arg4		=>  l_expenditure_type,
			 arg5		=>  null);



      wf_engine.SetItemAttrText
		( itemtype=> p_itemtype,
		  itemkey => p_itemkey,
		  aname	  => 'ERROR_MSG',
		  avalue  => 'Legal Entity Lookup Failed');



	x_result := 'COMPLETE:FAILURE';
	RETURN;
  END;

 BEGIN

    SELECT CASE WHEN
	(SELECT j.segment_value
	FROM pa.PA_SEGMENT_VALUE_LOOKUP_SETS i, pa.PA_SEGMENT_VALUE_LOOKUPS j
	WHERE i.segment_value_lookup_set_id = j.segment_value_lookup_set_id
	AND i.segment_value_lookup_set_name = 'ACCT-EXPENDITURE TYPE'
	AND j.segment_value_lookup = l_expenditure_type ) < 400000
	THEN '0000'
	ELSE '1999'
	END
	INTO l_segment_value_cc
	FROM DUAL;

 EXCEPTION

   WHEN no_data_found
    THEN


        wf_core.context( pkg_name	=> 'xxtm_pa_wf_pkg',
			 proc_name	=> 'xxtm_pa_wf_sql_fn',
			 arg1		=>  l_project_number,
			 arg2		=>  l_expenditure_type,
			 arg3		=>  l_expenditure_org_id,
			 arg4		=>  l_expenditure_type,
			 arg5		=>  null);


      wf_engine.SetItemAttrText
		( itemtype=> p_itemtype,
		  itemkey=> p_itemkey,
		  aname	=> 'ERROR_MSG',
		  avalue=> 'Cost Center lookup failed ');


	x_result := 'COMPLETE:FAILURE';
	RETURN;

 END;


      wf_engine.SetItemAttrText  ( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'TM_PA_PL',
				   avalue	=> l_segment_value_pl);

      wf_engine.SetItemAttrText  ( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'TM_PA_CC',
				   avalue	=> l_segment_value_cc);

      wf_engine.SetItemAttrText  ( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'TM_PA_LE',
				   avalue	=> l_segment_value_le);                   

  x_result := 'COMPLETE:SUCCESS';
  RETURN;

EXCEPTION

     WHEN OTHERS
       THEN


        wf_core.context( pkg_name	=> 'xxtm_pa_wf_pkg',
			 proc_name	=> 'xxtm_pa_wf_sql_fn',
			 arg1		=>  l_project_number,
			 arg2		=>  l_project_org_id,
			 arg3		=>  l_expenditure_org_id,
			 arg4		=>  l_expenditure_type,
			 arg5		=>  null);

        raise;

 END xxtm_pa_wf_sql_fn;

END xxtm_pa_wf_pkg;

/
