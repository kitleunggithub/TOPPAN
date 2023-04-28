--------------------------------------------------------
--  DDL for Package Body XXTM_CSV_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXTM_CSV_GENERATOR" AS
/*******************************************************************************
 *
 * Module Name : XXTM
 * Package Name: XXTM_CSV_GENERATOR
 *
 * Author      : DASH Kit Leung
 * Date        : 28-APR-2021
 *
 * Purpose     : This program propuse to convert SQL to CSV
 *
 * Name              Date          Remarks
 * ----------------- ------------- --------------------------------------------
 * DASH Kit Leung    28-APR-2021   Initial Release.
 *
 *******************************************************************************/

g_out_type    VARCHAR2(2) := 'F';
g_sep         VARCHAR2(5) := ',';
g_add_quotes  BOOLEAN     := TRUE;
g_quote_char  VARCHAR2(1) := '"';
g_escape      BOOLEAN     := TRUE;

-- Handle put to file or screen.
PROCEDURE put (p_file  IN  UTL_FILE.file_type,
               p_text  IN  VARCHAR2) AS
BEGIN
  IF g_out_type = 'F' THEN
    UTL_FILE.put(p_file, p_text);
  ELSIF g_out_type = 'O' THEN
    FND_FILE.PUT(FND_FILE.OUTPUT,p_text);
  ELSE
    DBMS_OUTPUT.put(p_text);
  END IF;
END put;


-- Handle newline to file or screen.
PROCEDURE new_line (p_file  IN  UTL_FILE.file_type) AS
BEGIN
  IF g_out_type = 'F' THEN
    UTL_FILE.new_line(p_file);
  ELSIF g_out_type = 'O' THEN
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
  ELSE
    DBMS_OUTPUT.new_line;
  END IF;
END new_line;

-- Do the actual work.
PROCEDURE generate_all (p_dir        IN  VARCHAR2,
                        p_file       IN  VARCHAR2,
                        p_query      IN  VARCHAR2,
                        p_refcursor  IN OUT  SYS_REFCURSOR) AS
  l_cursor    PLS_INTEGER;
  l_rows      PLS_INTEGER;
  l_col_cnt   PLS_INTEGER;
  l_desc_tab  DBMS_SQL.desc_tab2;
  l_buffer    VARCHAR2(32767);
  l_buffer_d  DATE;
  l_is_str    BOOLEAN;
  l_is_date   BOOLEAN;

  l_file      UTL_FILE.file_type;
BEGIN
  IF p_query IS NOT NULL THEN
    l_cursor := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(l_cursor, p_query, DBMS_SQL.native);
  ELSIF p_refcursor%ISOPEN THEN
     l_cursor := DBMS_SQL.to_cursor_number(p_refcursor);
  ELSE
    RAISE_APPLICATION_ERROR(-20000, 'You must specify a query or a REF CURSOR.');
  END IF;

  DBMS_SQL.describe_columns2 (l_cursor, l_col_cnt, l_desc_tab);

  FOR i IN 1 .. l_col_cnt LOOP
    IF l_desc_tab(i).col_type IN (DBMS_TYPES.typecode_date) THEN
        DBMS_SQL.define_column(l_cursor, i, l_buffer_d);    
    ELSE
        DBMS_SQL.define_column(l_cursor, i, l_buffer, 32767 );    
    END IF;

  END LOOP;

  IF p_query IS NOT NULL THEN
    l_rows := DBMS_SQL.execute(l_cursor);
  END IF;

  IF g_out_type = 'F' THEN
    l_file := UTL_FILE.fopen(p_dir, p_file, 'w', 32767);
  END IF;

  -- Output the column names.
  FOR i IN 1 .. l_col_cnt LOOP
    IF i > 1 THEN
      put(l_file, g_sep);
    END IF;
    put(l_file, l_desc_tab(i).col_name);
  END LOOP;
  new_line(l_file);

  -- Output the data.
  LOOP
    EXIT WHEN DBMS_SQL.fetch_rows(l_cursor) = 0;

    FOR i IN 1 .. l_col_cnt LOOP
      IF i > 1 THEN
        put(l_file, g_sep);
      END IF;

      -- Check if this is a string column.
      l_is_str := FALSE;
      l_is_date := FALSE;
      IF l_desc_tab(i).col_type IN (DBMS_TYPES.typecode_varchar,
                                    DBMS_TYPES.typecode_varchar2,
                                    DBMS_TYPES.typecode_char,
                                    DBMS_TYPES.typecode_clob,
                                    DBMS_TYPES.typecode_nvarchar2,
                                    DBMS_TYPES.typecode_nchar,
                                    DBMS_TYPES.typecode_nclob) THEN
        l_is_str := TRUE;
      -- Check if this is a date column.
      ELSIF l_desc_tab(i).col_type IN (DBMS_TYPES.typecode_date) THEN
        l_is_date:= TRUE;
      END IF;

      IF l_is_date THEN
        DBMS_SQL.COLUMN_VALUE(l_cursor, i, l_buffer_d);
        l_buffer := to_char(l_buffer_d,'DD-MON-YYYY HH24:MI:SS');
      ELSE
        DBMS_SQL.COLUMN_VALUE(l_cursor, i, l_buffer);
      END IF;

      -- Optionally add quotes for strings.
      IF g_add_quotes AND l_is_str  THEN
        put(l_file, g_quote_char);
        -- Optionally escape the quote character and the escape character in the string.
        IF g_escape THEN
          l_buffer := replace(l_buffer, '\', '\\');
          l_buffer := replace(l_buffer, g_quote_char, '\'||g_quote_char);
        END IF;
        put(l_file, l_buffer);
        put(l_file, g_quote_char);
      ELSE
        put(l_file, l_buffer);
      END IF;
    END LOOP;
    new_line(l_file);
  END LOOP;

  IF UTL_FILE.is_open(l_file) THEN
    UTL_FILE.fclose(l_file);
  END IF;
  DBMS_SQL.close_cursor(l_cursor);
EXCEPTION
  WHEN OTHERS THEN
    IF UTL_FILE.is_open(l_file) THEN
      UTL_FILE.fclose(l_file);
    END IF;
    IF DBMS_SQL.is_open(l_cursor) THEN
      DBMS_SQL.close_cursor(l_cursor);
    END IF;
    IF g_out_type IN ('F','O') THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || DBMS_UTILITY.FORMAT_ERROR_STACK);
    END IF;    
    DBMS_OUTPUT.put_line('ERROR: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || DBMS_UTILITY.FORMAT_ERROR_STACK);
    RAISE;
END generate_all;

-- call package to generate
PROCEDURE generate_proc ( p_dir        IN  VARCHAR2,
                          p_file       IN  VARCHAR2,
                          p_query      IN  VARCHAR2) 
AS
    l_query VARCHAR2(4000);
BEGIN
    l_query := p_query;    
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_query :='||p_query);
    EXECUTE IMMEDIATE p_query||';' USING p_dir,p_file;

    EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END generate_proc;

-- Concurrent Manager call to generate a CSV from a query.
PROCEDURE generate (errbuf       OUT VARCHAR2,
                    retcode      OUT NUMBER,
                    p_dir        IN  VARCHAR2,
                    p_file       IN  VARCHAR2,
                    p_out_type   IN  VARCHAR2,
                    p_query      IN  VARCHAR2) AS
  l_cursor  SYS_REFCURSOR;
BEGIN
  g_out_type := p_out_type;

  if g_out_type IN ('PD','PF','PO') then
      generate_proc (p_dir        => p_dir,
                     p_file       => p_file,
                     p_query      => p_query);
  else
      generate_all (p_dir        => p_dir,
                    p_file       => p_file,
                    p_query      => p_query,
                    p_refcursor  => l_cursor);
  end if;                  
EXCEPTION
WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := '2';        -- error
    fnd_file.put_line(fnd_file.log, errbuf);
END generate;


-- Stub to generate a CSV from a query.
PROCEDURE generate_file (p_dir        IN  VARCHAR2,
                         p_file       IN  VARCHAR2,
                         p_query      IN  VARCHAR2) AS
  l_cursor  SYS_REFCURSOR;
BEGIN
  g_out_type := 'F';

  generate_all (p_dir        => p_dir,
                p_file       => p_file,
                p_query      => p_query,
                p_refcursor  => l_cursor);
END generate_file;


-- Stub to generate a CVS from a REF CURSOR.
PROCEDURE generate_file_rc (p_dir        IN  VARCHAR2,
                            p_file       IN  VARCHAR2,
                            p_refcursor  IN OUT SYS_REFCURSOR) AS
BEGIN
  g_out_type := 'F';

  generate_all (p_dir        => p_dir,
                p_file       => p_file,
                p_query      => NULL,
                p_refcursor  => p_refcursor);
END generate_file_rc;


-- Stub to output a CSV from a query.
PROCEDURE output (p_query  IN  VARCHAR2) AS
  l_cursor  SYS_REFCURSOR;
BEGIN
  g_out_type := 'D';

  generate_all (p_dir        => NULL,
                p_file       => NULL,
                p_query      => p_query,
                p_refcursor  => l_cursor);
END output;


-- Stub to output a CVS from a REF CURSOR.
PROCEDURE output_rc (p_refcursor  IN OUT SYS_REFCURSOR) AS
BEGIN
  g_out_type := 'D';

  generate_all (p_dir        => NULL,
                p_file       => NULL,
                p_query      => NULL,
                p_refcursor  => p_refcursor);
END output_rc;

-- Alter separator from default.
PROCEDURE set_separator (p_sep  IN  VARCHAR2) AS
BEGIN
  g_sep := p_sep;
END set_separator;


-- Alter separator from default.
PROCEDURE set_quotes (p_add_quotes  IN  BOOLEAN := TRUE,
                      p_quote_char  IN  VARCHAR2 := '"',
                      p_escape      IN  BOOLEAN := TRUE) AS
BEGIN
  g_add_quotes := NVL(p_add_quotes, TRUE);
  g_quote_char := NVL(SUBSTR(p_quote_char,1,1), '"');
  g_escape     := NVL(p_escape, TRUE);
END set_quotes;

END XXTM_CSV_GENERATOR;


/
