CREATE FUNCTION xxgl_get_effective_period(x_ledger_id IN NUMBER, x_period_name IN VARCHAR2) 
    RETURN NUMBER 
IS 
    ln_eff_period NUMBER;
BEGIN 

    SELECT effective_period_num
    INTO ln_eff_period
    FROM gl_period_statuses 
    WHERE application_id = 101 
    AND ledger_id = x_ledger_id 
    AND period_name = x_period_name;
    
    RETURN ln_eff_period; 
END;
/

