CREATE TABLE chart_of_accounts (
    account_id VARCHAR(10),
    account_name VARCHAR(100) NOT NULL,
    normal_balance VARCHAR(6),
    report_classification VARCHAR(20),

    -- PK: ID akun harus unik dan tidak boleh NULL.
    CONSTRAINT pk_chart_of_accounts
        PRIMARY KEY (account_id),

    -- CHECK: saldo normal hanya boleh DEBIT atau CREDIT.
    CONSTRAINT chk_chart_of_accounts_normal_balance
        CHECK (normal_balance IN ('DEBIT', 'CREDIT')),

    -- CHECK: klasifikasi laporan hanya boleh NERACA atau LABA_RUGI.
    CONSTRAINT chk_chart_of_accounts_report_classification
        CHECK (report_classification IN ('NERACA', 'LABA_RUGI'))
);

CREATE TABLE journal_headers (
    header_id SERIAL,
    trx_date DATE NOT NULL DEFAULT CURRENT_DATE,
    reference_no VARCHAR(50) NOT NULL,
    description TEXT,
    status_posting VARCHAR(10) DEFAULT 'DRAFT',

    -- PK: ID header jurnal harus unik dan tidak boleh NULL.
    CONSTRAINT pk_journal_headers
        PRIMARY KEY (header_id),

    -- UNIQUE: nomor referensi tidak boleh digunakan lebih dari sekali.
    CONSTRAINT uq_journal_headers_reference_no
        UNIQUE (reference_no),

    -- CHECK: status posting hanya boleh DRAFT atau POSTED.
    CONSTRAINT chk_journal_headers_status_posting
        CHECK (status_posting IN ('DRAFT', 'POSTED'))
);

CREATE TABLE journal_lines (
    line_id SERIAL,
    header_id INT,
    account_id VARCHAR(10),
    debit NUMERIC(15, 2) NOT NULL DEFAULT 0,
    credit NUMERIC(15, 2) NOT NULL DEFAULT 0,

    -- PK: ID baris jurnal harus unik dan tidak boleh NULL.
    CONSTRAINT pk_journal_lines
        PRIMARY KEY (line_id),

    -- FK: header harus ada; header yang masih dirujuk tidak dapat dihapus.
    CONSTRAINT fk_journal_lines_header
        FOREIGN KEY (header_id)
        REFERENCES journal_headers (header_id)
        ON DELETE RESTRICT,

    -- FK: akun harus ada; akun yang masih dirujuk tidak dapat dihapus.
    CONSTRAINT fk_journal_lines_account
        FOREIGN KEY (account_id)
        REFERENCES chart_of_accounts (account_id)
        ON DELETE RESTRICT,

    -- CHECK: debit tidak boleh negatif.
    CONSTRAINT chk_journal_lines_debit_nonnegative
        CHECK (debit >= 0),

    -- CHECK: kredit tidak boleh negatif.
    CONSTRAINT chk_journal_lines_credit_nonnegative
        CHECK (credit >= 0),

    -- CHECK: debit dan kredit tidak boleh sama-sama nol.
    CONSTRAINT chk_journal_lines_nonzero_amount
        CHECK (debit > 0 OR credit > 0),

    -- CHECK: debit dan kredit tidak boleh sama-sama positif.
    CONSTRAINT chk_journal_lines_one_sided
        CHECK (debit = 0 OR credit = 0)
);