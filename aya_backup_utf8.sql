--
-- PostgreSQL database dump
--

\restrict GeH7a0kbwNuaMChB2av5um5hfkdoubu9iLviCA3FmZVq19WqIhg9gLjWbFP0c9y

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ads (
    id integer NOT NULL,
    title character varying(150),
    image_url text NOT NULL,
    link_url text,
    sort_order integer DEFAULT 0,
    created_by integer,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.ads OWNER TO postgres;

--
-- Name: ads_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ads_id_seq OWNER TO postgres;

--
-- Name: ads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ads_id_seq OWNED BY public.ads.id;


--
-- Name: aes_content; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.aes_content (
    id integer NOT NULL,
    what_is_aes text,
    history text,
    objectives text,
    donation_contact character varying(15),
    progress_current numeric(12,2) DEFAULT 0,
    progress_target numeric(12,2) DEFAULT 0,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.aes_content OWNER TO postgres;

--
-- Name: aes_content_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.aes_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.aes_content_id_seq OWNER TO postgres;

--
-- Name: aes_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.aes_content_id_seq OWNED BY public.aes_content.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    actor_id integer,
    action text NOT NULL,
    target_id integer,
    target_type character varying(50),
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_id_seq OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: event_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_assignments (
    id integer NOT NULL,
    event_id integer NOT NULL,
    member_id integer NOT NULL,
    assigned_by integer,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.event_assignments OWNER TO postgres;

--
-- Name: event_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.event_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.event_assignments_id_seq OWNER TO postgres;

--
-- Name: event_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.event_assignments_id_seq OWNED BY public.event_assignments.id;


--
-- Name: event_labarthis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_labarthis (
    id integer NOT NULL,
    event_id integer NOT NULL,
    name character varying(150) NOT NULL,
    amount numeric(12,2),
    note text,
    added_by integer,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.event_labarthis OWNER TO postgres;

--
-- Name: event_labarthis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.event_labarthis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.event_labarthis_id_seq OWNER TO postgres;

--
-- Name: event_labarthis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.event_labarthis_id_seq OWNED BY public.event_labarthis.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    id integer NOT NULL,
    vibhag_type character varying(30) NOT NULL,
    name character varying(150) NOT NULL,
    date date NOT NULL,
    "time" time without time zone,
    venue character varying(200),
    labarthi character varying(200),
    description text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    updated_by integer,
    end_date date,
    end_time time without time zone,
    members_locked boolean DEFAULT false NOT NULL,
    members_locked_by integer,
    members_locked_at timestamp with time zone,
    members_updated_at timestamp with time zone
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.events_id_seq OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: gallery_albums; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gallery_albums (
    id integer NOT NULL,
    title character varying(150) NOT NULL,
    description text,
    event_id integer,
    cover_url text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now(),
    year integer
);


ALTER TABLE public.gallery_albums OWNER TO postgres;

--
-- Name: gallery_albums_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gallery_albums_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gallery_albums_id_seq OWNER TO postgres;

--
-- Name: gallery_albums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gallery_albums_id_seq OWNED BY public.gallery_albums.id;


--
-- Name: gallery_photos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gallery_photos (
    id integer NOT NULL,
    album_id integer NOT NULL,
    image_url text NOT NULL,
    caption character varying(200),
    uploaded_by integer,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.gallery_photos OWNER TO postgres;

--
-- Name: gallery_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gallery_photos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gallery_photos_id_seq OWNER TO postgres;

--
-- Name: gallery_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gallery_photos_id_seq OWNED BY public.gallery_photos.id;


--
-- Name: member_children; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.member_children (
    id integer NOT NULL,
    member_id integer,
    name character varying(100),
    dob date,
    contact character varying(15),
    photo_url text,
    photo_drive_id text,
    sort_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.member_children OWNER TO postgres;

--
-- Name: member_children_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.member_children_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.member_children_id_seq OWNER TO postgres;

--
-- Name: member_children_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.member_children_id_seq OWNED BY public.member_children.id;


--
-- Name: member_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.member_profiles (
    id integer NOT NULL,
    member_id integer,
    full_name character varying(100),
    email character varying(100),
    dob date,
    anniversary_date date,
    native_place character varying(100),
    blood_group character varying(5),
    photo_url text,
    photo_drive_id text,
    res_address text,
    res_phone character varying(15),
    office_address text,
    office_phone character varying(15),
    mandal_category character varying(50),
    mandal_position character varying(50),
    spouse_name character varying(100),
    spouse_mobile character varying(15),
    spouse_dob date,
    spouse_photo_url text,
    spouse_photo_drive_id text,
    profile_complete_pct integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.member_profiles OWNER TO postgres;

--
-- Name: member_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.member_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.member_profiles_id_seq OWNER TO postgres;

--
-- Name: member_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.member_profiles_id_seq OWNED BY public.member_profiles.id;


--
-- Name: members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.members (
    id integer NOT NULL,
    mobile character varying(15) NOT NULL,
    password_hash text NOT NULL,
    role character varying(20) DEFAULT 'member'::character varying,
    role_status character varying(20) DEFAULT 'approved'::character varying,
    status character varying(10) DEFAULT 'active'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.members OWNER TO postgres;

--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.members_id_seq OWNER TO postgres;

--
-- Name: members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.members_id_seq OWNED BY public.members.id;


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    id integer NOT NULL,
    member_id integer,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.refresh_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.refresh_tokens_id_seq OWNER TO postgres;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- Name: vibhag_heads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vibhag_heads (
    id integer NOT NULL,
    vibhag_type character varying(30) NOT NULL,
    member_id integer NOT NULL,
    assigned_by integer,
    assigned_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.vibhag_heads OWNER TO postgres;

--
-- Name: vibhag_heads_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vibhag_heads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vibhag_heads_id_seq OWNER TO postgres;

--
-- Name: vibhag_heads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vibhag_heads_id_seq OWNED BY public.vibhag_heads.id;


--
-- Name: vibhags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vibhags (
    type character varying(30) NOT NULL,
    name character varying(60) NOT NULL,
    description text,
    color character varying(9) DEFAULT '#2992D6'::character varying NOT NULL,
    icon character varying(40) DEFAULT 'event'::character varying NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.vibhags OWNER TO postgres;

--
-- Name: ads id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ads ALTER COLUMN id SET DEFAULT nextval('public.ads_id_seq'::regclass);


--
-- Name: aes_content id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aes_content ALTER COLUMN id SET DEFAULT nextval('public.aes_content_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: event_assignments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_assignments ALTER COLUMN id SET DEFAULT nextval('public.event_assignments_id_seq'::regclass);


--
-- Name: event_labarthis id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_labarthis ALTER COLUMN id SET DEFAULT nextval('public.event_labarthis_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: gallery_albums id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_albums ALTER COLUMN id SET DEFAULT nextval('public.gallery_albums_id_seq'::regclass);


--
-- Name: gallery_photos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_photos ALTER COLUMN id SET DEFAULT nextval('public.gallery_photos_id_seq'::regclass);


--
-- Name: member_children id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member_children ALTER COLUMN id SET DEFAULT nextval('public.member_children_id_seq'::regclass);


--
-- Name: member_profiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member_profiles ALTER COLUMN id SET DEFAULT nextval('public.member_profiles_id_seq'::regclass);


--
-- Name: members id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members ALTER COLUMN id SET DEFAULT nextval('public.members_id_seq'::regclass);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- Name: vibhag_heads id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vibhag_heads ALTER COLUMN id SET DEFAULT nextval('public.vibhag_heads_id_seq'::regclass);


--
-- Data for Name: ads; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ads (id, title, image_url, link_url, sort_order, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: aes_content; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.aes_content (id, what_is_aes, history, objectives, donation_contact, progress_current, progress_target, updated_at) FROM stdin;
1	Aradhana Education Society (AES) supports the education of children and youth in our community.	AES was started by the Aradhana Youth Association to extend its work beyond events into education and welfare.	Provide scholarships, learning materials and mentorship to deserving students of the community.	9876767676	0.00	0.00	2026-06-14 19:53:50.123189+05:30
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, actor_id, action, target_id, target_type, metadata, created_at) FROM stdin;
1	1	LOGIN	1	member	\N	2026-06-12 16:08:43.454852+05:30
2	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:08:43.46203+05:30
3	1	LOGOUT	1	member	\N	2026-06-12 16:08:56.763132+05:30
4	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:08:56.765158+05:30
5	1	LOGIN	1	member	\N	2026-06-12 16:09:38.241944+05:30
6	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:09:38.244428+05:30
7	1	LOGOUT	1	member	\N	2026-06-12 16:11:28.583605+05:30
8	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:11:28.585222+05:30
9	1	LOGIN	1	member	\N	2026-06-12 16:11:48.52149+05:30
10	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:11:48.523812+05:30
11	1	LOGOUT	1	member	\N	2026-06-12 16:11:52.61333+05:30
12	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:11:52.614756+05:30
13	\N	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 401}	2026-06-12 16:12:06.675727+05:30
14	1	LOGIN	1	member	\N	2026-06-12 16:27:21.511388+05:30
15	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:27:21.518053+05:30
16	1	ADD_MEMBER	2	member	{"mobile": "9841312249"}	2026-06-12 16:28:53.990421+05:30
17	1	POST /api/admin/members	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-12 16:28:53.993473+05:30
18	1	LOGOUT	1	member	\N	2026-06-12 16:29:07.305727+05:30
19	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:29:07.308432+05:30
20	2	LOGIN	2	member	\N	2026-06-12 16:29:21.915227+05:30
21	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:29:21.918053+05:30
22	2	LOGOUT	2	member	\N	2026-06-12 16:29:42.950441+05:30
23	2	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:29:42.952346+05:30
24	1	LOGIN	1	member	\N	2026-06-12 16:29:59.803725+05:30
25	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:29:59.807216+05:30
26	1	CHANGE_MEMBER_STATUS	2	member	{"status": "inactive"}	2026-06-12 16:30:07.939219+05:30
27	1	PATCH /api/admin/members/2/status	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:30:07.941141+05:30
28	1	LOGOUT	1	member	\N	2026-06-12 16:30:10.571364+05:30
29	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 16:30:10.572728+05:30
30	\N	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 403}	2026-06-12 16:30:27.940718+05:30
31	\N	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 403}	2026-06-12 17:14:17.403636+05:30
32	1	LOGIN	1	member	\N	2026-06-12 17:14:39.274773+05:30
33	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 17:14:39.278429+05:30
34	1	CHANGE_MEMBER_STATUS	2	member	{"status": "active"}	2026-06-12 17:18:35.427808+05:30
35	1	PATCH /api/admin/members/2/status	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 17:18:35.430697+05:30
36	1	LOGOUT	1	member	\N	2026-06-12 17:18:40.023908+05:30
37	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 17:18:40.025205+05:30
38	2	LOGIN	2	member	\N	2026-06-12 17:18:57.972002+05:30
39	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 17:18:57.974855+05:30
40	2	UPDATE_PROFILE	2	member	\N	2026-06-12 17:22:22.918264+05:30
41	2	PUT /api/profile/me	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 17:22:22.920465+05:30
42	2	LOGOUT	2	member	\N	2026-06-12 19:54:52.760346+05:30
43	2	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 19:54:52.766347+05:30
44	2	LOGIN	2	member	\N	2026-06-12 20:00:12.630058+05:30
45	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:00:12.632721+05:30
46	2	LOGOUT	2	member	\N	2026-06-12 20:00:54.319677+05:30
47	2	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:00:54.322243+05:30
48	1	LOGIN	1	member	\N	2026-06-12 20:01:13.852334+05:30
49	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:01:13.855011+05:30
50	1	LOGOUT	1	member	\N	2026-06-12 20:02:26.10263+05:30
51	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:02:26.104492+05:30
52	2	LOGIN	2	member	\N	2026-06-12 20:02:44.242091+05:30
53	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:02:44.244431+05:30
54	2	LOGOUT	2	member	\N	2026-06-12 20:06:42.635418+05:30
55	2	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:06:42.637359+05:30
56	1	LOGIN	1	member	\N	2026-06-12 20:07:04.68361+05:30
57	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:07:04.68589+05:30
58	1	LOGOUT	1	member	\N	2026-06-12 20:07:13.262063+05:30
59	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:07:13.263858+05:30
60	2	LOGIN	2	member	\N	2026-06-12 20:07:39.371091+05:30
61	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:07:39.373129+05:30
62	2	LOGOUT	2	member	\N	2026-06-12 20:07:53.364416+05:30
63	2	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:07:53.366522+05:30
64	2	LOGIN	2	member	\N	2026-06-12 20:20:31.96477+05:30
65	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:20:31.972062+05:30
66	2	LOGOUT	2	member	\N	2026-06-12 20:43:16.357105+05:30
67	2	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:43:16.360643+05:30
68	1	LOGIN	1	member	\N	2026-06-12 20:43:33.464742+05:30
69	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:43:33.468395+05:30
70	1	LOGOUT	1	member	\N	2026-06-12 20:43:41.604027+05:30
71	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:43:41.606158+05:30
72	2	LOGIN	2	member	\N	2026-06-12 20:43:59.065386+05:30
73	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:43:59.068861+05:30
74	2	UPDATE_PROFILE	2	member	\N	2026-06-12 20:48:26.944424+05:30
75	2	PUT /api/profile/me	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:48:26.953235+05:30
76	2	POST /api/profile/children	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-12 20:49:51.246715+05:30
77	2	DELETE /api/profile/children/1	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:49:59.48217+05:30
78	2	POST /api/profile/children	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-12 20:50:21.529508+05:30
79	2	UPDATE_PROFILE	2	member	\N	2026-06-12 20:50:26.717525+05:30
80	2	PUT /api/profile/me	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:50:26.720561+05:30
81	2	UPDATE_PROFILE	2	member	\N	2026-06-12 20:50:36.518278+05:30
82	2	PUT /api/profile/me	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 20:50:36.519719+05:30
83	2	UPDATE_PROFILE	2	member	\N	2026-06-12 21:10:31.284023+05:30
84	2	PUT /api/profile/me	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-12 21:10:31.301976+05:30
85	2	LOGOUT	2	member	\N	2026-06-13 16:56:50.913639+05:30
86	2	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 16:56:50.980471+05:30
87	1	LOGIN	1	member	\N	2026-06-13 16:57:07.054545+05:30
88	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 16:57:07.057481+05:30
89	1	LOGOUT	1	member	\N	2026-06-13 16:57:16.808963+05:30
90	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 16:57:16.812463+05:30
91	2	LOGIN	2	member	\N	2026-06-13 16:58:05.412732+05:30
92	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 16:58:05.415892+05:30
93	1	LOGIN	1	member	\N	2026-06-13 17:10:20.953826+05:30
94	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 17:10:20.958781+05:30
95	1	CREATE_EVENT	5	event	{"name": "Paryushan Mahaparv", "vibhag_type": "paryushan"}	2026-06-13 17:10:21.034266+05:30
96	1	POST /api/events	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-13 17:10:21.036625+05:30
97	1	POST /api/events	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 400}	2026-06-13 17:10:21.051423+05:30
98	1	ADD_MEMBER	7	member	{"mobile": "9084816220"}	2026-06-13 17:10:21.367952+05:30
99	1	POST /api/admin/members	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-13 17:10:21.369418+05:30
100	7	LOGIN	7	member	\N	2026-06-13 17:10:21.671184+05:30
101	7	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 17:10:21.672786+05:30
102	7	POST /api/events	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 403}	2026-06-13 17:10:21.681358+05:30
103	7	POST /api/vibhags/seva/heads	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 403}	2026-06-13 17:10:21.693811+05:30
104	1	ADD_VIBHAG_HEAD	7	member	{"vibhag_type": "sangeet"}	2026-06-13 17:10:21.703715+05:30
105	1	POST /api/vibhags/sangeet/heads	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-13 17:10:21.70869+05:30
106	7	CREATE_EVENT	6	event	{"name": "Bhakti Sandhya", "vibhag_type": "sangeet"}	2026-06-13 17:10:21.725138+05:30
107	7	POST /api/events	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-13 17:10:21.726835+05:30
108	7	POST /api/events	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 403}	2026-06-13 17:10:21.733134+05:30
109	7	REQUEST_SPONSORSHIP	5	event	{"sponsorship_id": 1}	2026-06-13 17:10:21.746713+05:30
110	7	POST /api/events/5/sponsorships	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-13 17:10:21.748+05:30
111	7	POST /api/events/5/sponsorships	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 409}	2026-06-13 17:10:21.754799+05:30
112	1	DECIDE_SPONSORSHIP	1	sponsorship	{"status": "approved", "event_id": 5}	2026-06-13 17:10:21.776843+05:30
113	1	PATCH /api/events/5/sponsorships/1	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 17:10:21.778201+05:30
114	1	DELETE_EVENT	5	event	{"name": "Paryushan Mahaparv"}	2026-06-13 17:10:21.836105+05:30
115	1	DELETE /api/events/5	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 17:10:21.838742+05:30
116	1	REMOVE_VIBHAG_HEAD	7	member	{"vibhag_type": "sangeet"}	2026-06-13 17:10:21.848568+05:30
117	1	DELETE /api/vibhags/sangeet/heads/7	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 17:10:21.852193+05:30
118	1	CHANGE_MEMBER_STATUS	7	member	{"status": "inactive"}	2026-06-13 17:10:21.861714+05:30
119	1	PATCH /api/admin/members/7/status	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 17:10:21.862809+05:30
120	2	DELETE_EVENT	6	event	{"name": "Bhakti Sandhya"}	2026-06-13 18:36:32.093535+05:30
121	2	DELETE /api/events/6	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-13 18:36:32.100641+05:30
122	2	LOGOUT	2	member	\N	2026-06-14 16:04:46.102302+05:30
123	2	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 16:04:46.131306+05:30
124	2	LOGIN	2	member	\N	2026-06-14 16:12:09.144502+05:30
125	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 16:12:09.147402+05:30
126	2	CREATE_EVENT	7	event	{"name": "Aangi", "vibhag_type": "aangi"}	2026-06-14 17:31:26.633481+05:30
127	2	POST /api/events	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-14 17:31:26.63935+05:30
128	2	CREATE_EVENT	8	event	{"name": "paryushan", "vibhag_type": "paryushan"}	2026-06-14 17:56:46.537023+05:30
129	2	POST /api/events	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-14 17:56:46.540794+05:30
130	2	ADD_LABARTHI	8	event	{"labarthi_id": 1}	2026-06-14 17:57:07.069633+05:30
131	2	POST /api/events/8/labarthis	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-14 17:57:07.072536+05:30
132	2	SET_EVENT_MEMBERS	8	event	{"count": 1, "while_locked": false}	2026-06-14 18:20:06.75998+05:30
133	2	PUT /api/events/8/assignments	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:20:06.763371+05:30
134	2	SET_EVENT_MEMBERS	8	event	{"count": 1, "while_locked": false}	2026-06-14 18:20:30.128956+05:30
135	2	PUT /api/events/8/assignments	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:20:30.131114+05:30
136	2	SET_EVENT_MEMBERS	7	event	{"count": 1, "while_locked": false}	2026-06-14 18:20:46.369606+05:30
137	2	PUT /api/events/7/assignments	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:20:46.37078+05:30
138	2	LOGOUT	2	member	\N	2026-06-14 18:21:20.822791+05:30
139	2	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:21:20.826143+05:30
140	1	LOGIN	1	member	\N	2026-06-14 18:21:39.119218+05:30
141	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:21:39.122007+05:30
142	1	LOGOUT	1	member	\N	2026-06-14 18:22:38.908286+05:30
143	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:22:38.909757+05:30
144	2	LOGIN	2	member	\N	2026-06-14 18:23:01.501756+05:30
145	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:23:01.504289+05:30
146	2	SET_EVENT_MEMBERS	7	event	{"count": 2, "while_locked": false}	2026-06-14 18:26:22.427434+05:30
147	2	PUT /api/events/7/assignments	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:26:22.430665+05:30
148	2	CREATE_ALBUM	1	album	\N	2026-06-14 18:46:59.744135+05:30
149	2	POST /api/gallery/albums	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 201}	2026-06-14 18:46:59.747611+05:30
150	2	LOGOUT	2	member	\N	2026-06-14 18:47:43.156323+05:30
151	2	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:47:43.15961+05:30
152	1	LOGIN	1	member	\N	2026-06-14 18:47:56.967592+05:30
153	1	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:47:56.970063+05:30
154	1	LOCK_EVENT_MEMBERS	7	event	\N	2026-06-14 18:52:12.992596+05:30
155	1	PATCH /api/events/7/members-lock	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:52:12.997441+05:30
156	1	UNLOCK_EVENT_MEMBERS	7	event	\N	2026-06-14 18:52:18.14303+05:30
157	1	PATCH /api/events/7/members-lock	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:52:18.145991+05:30
158	1	LOGOUT	1	member	\N	2026-06-14 18:56:48.233968+05:30
159	1	POST /api/auth/logout	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:56:48.243105+05:30
160	\N	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 401}	2026-06-14 18:57:43.113551+05:30
161	2	LOGIN	2	member	\N	2026-06-14 18:58:00.179825+05:30
162	2	POST /api/auth/login	\N	\N	{"ip": "::ffff:127.0.0.1", "status": 200}	2026-06-14 18:58:00.183685+05:30
\.


--
-- Data for Name: event_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_assignments (id, event_id, member_id, assigned_by, created_at) FROM stdin;
2	8	2	2	2026-06-14 18:20:30.124949+05:30
4	7	1	2	2026-06-14 18:26:22.422572+05:30
5	7	2	2	2026-06-14 18:26:22.422572+05:30
\.


--
-- Data for Name: event_labarthis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_labarthis (id, event_id, name, amount, note, added_by, created_at) FROM stdin;
1	8	abc shah	5000.00	\N	2	2026-06-14 17:57:07.032916+05:30
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (id, vibhag_type, name, date, "time", venue, labarthi, description, created_by, created_at, updated_at, updated_by, end_date, end_time, members_locked, members_locked_by, members_locked_at, members_updated_at) FROM stdin;
8	paryushan	paryushan	2026-09-16	19:00:00	jain upashray	\N	\N	2	2026-06-14 17:56:46.512308+05:30	2026-06-14 17:56:46.512308+05:30	\N	2026-09-24	21:00:00	f	\N	\N	2026-06-14 18:20:30.124949+05:30
7	aangi	Aangi	2026-06-18	10:30:00	Adinathnagar society	\N	\N	2	2026-06-14 17:31:26.601118+05:30	2026-06-14 17:31:26.601118+05:30	\N	2026-06-19	\N	f	1	2026-06-14 18:52:12.988299+05:30	2026-06-14 18:26:22.422572+05:30
\.


--
-- Data for Name: gallery_albums; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gallery_albums (id, title, description, event_id, cover_url, created_by, created_at, year) FROM stdin;
1	Paryushan	\N	\N	\N	2	2026-06-14 18:46:59.727258+05:30	2026
\.


--
-- Data for Name: gallery_photos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gallery_photos (id, album_id, image_url, caption, uploaded_by, created_at) FROM stdin;
\.


--
-- Data for Name: member_children; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.member_children (id, member_id, name, dob, contact, photo_url, photo_drive_id, sort_order, created_at) FROM stdin;
2	2	pratyush	2006-01-28	9764616466	\N	\N	0	2026-06-12 20:50:21.406673+05:30
\.


--
-- Data for Name: member_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.member_profiles (id, member_id, full_name, email, dob, anniversary_date, native_place, blood_group, photo_url, photo_drive_id, res_address, res_phone, office_address, office_phone, mandal_category, mandal_position, spouse_name, spouse_mobile, spouse_dob, spouse_photo_url, spouse_photo_drive_id, profile_complete_pct, created_at, updated_at) FROM stdin;
1	2	Lucky	lucky@gmail.com	1992-12-31	2000-03-07	Madras	A+	\N	\N	Abc, park avenue street, xyz-04	9746163518	B-1 abhishek estate,  salpur-09	9841312249	General	Member	Khusbu	9467646611	1993-06-12	\N	\N	92	2026-06-12 17:22:22.834889+05:30	2026-06-12 21:10:31.275611+05:30
\.


--
-- Data for Name: members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.members (id, mobile, password_hash, role, role_status, status, created_at, updated_at) FROM stdin;
1	9876767676	$2a$12$2oE6tDfY3W416GpdbwBbUO3xrQDaWs2vBYjJPU1BIFYIV8s89jgvm	president	approved	active	2026-06-12 16:07:50.81522+05:30	2026-06-12 16:07:50.81522+05:30
2	9841312249	$2a$12$.Lj/j8jmeCVpeffUywcFS.G6X1Zb2f5QdQ.u/tQOwlz1JXC1m4q7u	member	approved	active	2026-06-12 16:28:53.976929+05:30	2026-06-12 17:18:35.422957+05:30
7	9084816220	$2a$12$7nLqovhOHV4WWPUIW4Z7BOt7mYMI.IbKNVWSh3ZF7SNS/4H2IGk/.	member	approved	inactive	2026-06-13 17:10:21.360572+05:30	2026-06-13 17:10:21.856845+05:30
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens (id, member_id, token_hash, expires_at, revoked, created_at) FROM stdin;
1	1	be1c062970a8e597765503a99ee1da586f65d02f61e573e048747039ad133873	2026-07-12 16:08:43.448+05:30	t	2026-06-12 16:08:43.450688+05:30
2	1	20dd0dd524ead7622ff7440044c19e91eff384e6e3bdddded4734b8c473a401e	2026-07-12 16:09:38.237+05:30	t	2026-06-12 16:09:38.239125+05:30
3	1	c0c9bebf9c9ce1772fa7d626fc02e68e8485699681c34a456dce234d31d48389	2026-07-12 16:11:48.506+05:30	t	2026-06-12 16:11:48.507582+05:30
4	1	f9f06c53a43ee374d668d9a4583fd1df40e798ed8d2fa77d287dcbfef204b31c	2026-07-12 16:27:21.495+05:30	t	2026-06-12 16:27:21.497322+05:30
5	2	b26b72f7e3ceff5adbc2ed609776e49039bd060131b37e7f0df812347fd2b5b3	2026-07-12 16:29:21.899+05:30	t	2026-06-12 16:29:21.901068+05:30
6	1	fb11718372192b68517a9198883c0329eeb79dd0e9f4933f3509152395a23e82	2026-07-12 16:29:59.799+05:30	t	2026-06-12 16:29:59.800017+05:30
7	1	e661c792fbb2c05f02307e42a1b3c264cc1b1b4cf9c2a0a898cd63b7daf4ac01	2026-07-12 17:14:39.26+05:30	t	2026-06-12 17:14:39.267713+05:30
8	2	78983c33a02a40b4ba05f37650e9a1bd7e3bb36b2ca620c6a40c602b8fdf6722	2026-07-12 17:18:57.965+05:30	t	2026-06-12 17:18:57.967121+05:30
9	2	5a9f1fdf4e5db8ce4e7715f17a941683f6dc09d0b2594157a46fb1a8ab3e10b1	2026-07-12 20:00:12.621+05:30	t	2026-06-12 20:00:12.622574+05:30
10	1	56d462346ada787a12e985ff2cb86847bcf44685ef2d7ab26ec69c41929774a0	2026-07-12 20:01:13.837+05:30	t	2026-06-12 20:01:13.838375+05:30
11	2	9eabd24a7e0373cb198af688d6285febf4ce02825b64d49813fc159c3c46b19e	2026-07-12 20:02:44.227+05:30	t	2026-06-12 20:02:44.22822+05:30
12	1	54b657f9fa99b9b57d8efcbc3396c7146ba1bd8607ae5c1fe7dbace095f4ef62	2026-07-12 20:07:04.676+05:30	t	2026-06-12 20:07:04.67786+05:30
13	2	9216ed6d2e5a6855968973f56ce0d8e9ebdf4c86bdfcf3cd312e49cfa75ab6b1	2026-07-12 20:07:39.367+05:30	t	2026-06-12 20:07:39.368051+05:30
14	2	2f512ae6668d46eb27b3bd8b47afb5f6b6c4a3db3151f5d28941b72e3cfa5e98	2026-07-12 20:20:31.957+05:30	t	2026-06-12 20:20:31.960359+05:30
15	1	8412cfac63af4fb6662e80345029a4d9ba38778a993d4fb69e409d68abf41d2d	2026-07-12 20:43:33.447+05:30	t	2026-06-12 20:43:33.449616+05:30
16	2	355fb892aedc85cce414758508bf2445798c6f5dd2a014abee90bf14d463a85f	2026-07-12 20:43:59.059+05:30	t	2026-06-12 20:43:59.06012+05:30
17	1	b03759eace1636d28b729567eaa5b10742021295d2715cf5205b13528ca856a5	2026-07-13 16:57:07.047+05:30	t	2026-06-13 16:57:07.049148+05:30
19	1	795eac691ebb22dfc42678a69a9abe575593d780b85abbcd3de901255bd933fc	2026-07-13 17:10:20.923+05:30	f	2026-06-13 17:10:20.925631+05:30
20	7	9647c6d3424721b641d3be08f5f4203e71bfbad1f2645921860fa6cccf625370	2026-07-13 17:10:21.667+05:30	t	2026-06-13 17:10:21.668764+05:30
18	2	adfceef1fd23e746e05cf139d24f4e31a2a011279aedeff34409c535f3038f12	2026-07-13 16:58:05.397+05:30	t	2026-06-13 16:58:05.398816+05:30
21	2	7e16211263dff57cf135e556648a962abe56621843d87f10c95dc02c28a710cc	2026-07-14 16:12:09.136+05:30	t	2026-06-14 16:12:09.138074+05:30
22	1	1a999cb77b36479a2802588c8e151db10f7f827d84dbea6947ac6a93c7ec5d44	2026-07-14 18:21:39.103+05:30	t	2026-06-14 18:21:39.104107+05:30
23	2	dacb87c5ceac196fe8dc6ee5fde164da69a2cd49a5c5931942e1ba6c426a3f37	2026-07-14 18:23:01.487+05:30	t	2026-06-14 18:23:01.488409+05:30
24	1	f428ecb139fde5fab96828a214a8e5f215a9efc282b02f364e9ffddf231041a5	2026-07-14 18:47:56.962+05:30	t	2026-06-14 18:47:56.963742+05:30
25	2	59482196df48b3f382f6008cf9baf99166d3e32e6ffa5fc02d5744a47dff0d6c	2026-07-14 18:58:00.164+05:30	f	2026-06-14 18:58:00.165615+05:30
\.


--
-- Data for Name: vibhag_heads; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vibhag_heads (id, vibhag_type, member_id, assigned_by, assigned_at) FROM stdin;
\.


--
-- Data for Name: vibhags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vibhags (type, name, description, color, icon, sort_order, created_at, updated_at) FROM stdin;
paryushan	Paryushan	The great festival of forgiveness, fasting and reflection ΓÇö the spiritual high point of the Jain year.	#E8940A	local_fire_department	1	2026-06-13 16:53:57.006574+05:30	2026-06-13 16:53:57.006574+05:30
snatra	Snatra Puja	Daily and occasion abhishek of the Jina, performed with devotion and ritual purity.	#2992D6	spa	2	2026-06-13 16:53:57.006574+05:30	2026-06-13 16:53:57.006574+05:30
sangeet	Sangeet	Devotional music and bhakti ΓÇö bhavnas, stavans and community singing.	#7C3AED	music_note	3	2026-06-13 16:53:57.006574+05:30	2026-06-13 16:53:57.006574+05:30
aangi	Aangi	Adornment and decoration of the idol for festivals and special occasions.	#EF4444	checkroom	4	2026-06-13 16:53:57.006574+05:30	2026-06-13 16:53:57.006574+05:30
seva	Seva	Selfless community service ΓÇö supporting members, events and those in need.	#10B981	volunteer_activism	5	2026-06-13 16:53:57.006574+05:30	2026-06-13 16:53:57.006574+05:30
jeev_daya	Jeev Daya	Compassion for all living beings ΓÇö animal welfare and protection of life.	#0D9488	eco	6	2026-06-13 16:53:57.006574+05:30	2026-06-13 16:53:57.006574+05:30
\.


--
-- Name: ads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ads_id_seq', 1, false);


--
-- Name: aes_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.aes_content_id_seq', 1, true);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 162, true);


--
-- Name: event_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.event_assignments_id_seq', 5, true);


--
-- Name: event_labarthis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.event_labarthis_id_seq', 1, true);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.events_id_seq', 8, true);


--
-- Name: gallery_albums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gallery_albums_id_seq', 1, true);


--
-- Name: gallery_photos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gallery_photos_id_seq', 1, false);


--
-- Name: member_children_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.member_children_id_seq', 2, true);


--
-- Name: member_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.member_profiles_id_seq', 5, true);


--
-- Name: members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.members_id_seq', 15, true);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 25, true);


--
-- Name: vibhag_heads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vibhag_heads_id_seq', 1, true);


--
-- Name: ads ads_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ads
    ADD CONSTRAINT ads_pkey PRIMARY KEY (id);


--
-- Name: aes_content aes_content_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.aes_content
    ADD CONSTRAINT aes_content_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: event_assignments event_assignments_event_id_member_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_assignments
    ADD CONSTRAINT event_assignments_event_id_member_id_key UNIQUE (event_id, member_id);


--
-- Name: event_assignments event_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_assignments
    ADD CONSTRAINT event_assignments_pkey PRIMARY KEY (id);


--
-- Name: event_labarthis event_labarthis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_labarthis
    ADD CONSTRAINT event_labarthis_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: gallery_albums gallery_albums_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_albums
    ADD CONSTRAINT gallery_albums_pkey PRIMARY KEY (id);


--
-- Name: gallery_photos gallery_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_photos
    ADD CONSTRAINT gallery_photos_pkey PRIMARY KEY (id);


--
-- Name: member_children member_children_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member_children
    ADD CONSTRAINT member_children_pkey PRIMARY KEY (id);


--
-- Name: member_profiles member_profiles_member_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member_profiles
    ADD CONSTRAINT member_profiles_member_id_key UNIQUE (member_id);


--
-- Name: member_profiles member_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member_profiles
    ADD CONSTRAINT member_profiles_pkey PRIMARY KEY (id);


--
-- Name: members members_mobile_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_mobile_key UNIQUE (mobile);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: vibhag_heads vibhag_heads_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vibhag_heads
    ADD CONSTRAINT vibhag_heads_pkey PRIMARY KEY (id);


--
-- Name: vibhag_heads vibhag_heads_vibhag_type_member_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vibhag_heads
    ADD CONSTRAINT vibhag_heads_vibhag_type_member_id_key UNIQUE (vibhag_type, member_id);


--
-- Name: vibhags vibhags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vibhags
    ADD CONSTRAINT vibhags_pkey PRIMARY KEY (type);


--
-- Name: idx_assignments_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_assignments_event ON public.event_assignments USING btree (event_id);


--
-- Name: idx_assignments_member; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_assignments_member ON public.event_assignments USING btree (member_id);


--
-- Name: idx_events_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_events_date ON public.events USING btree (date);


--
-- Name: idx_events_end_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_events_end_date ON public.events USING btree (end_date);


--
-- Name: idx_events_vibhag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_events_vibhag ON public.events USING btree (vibhag_type);


--
-- Name: idx_gallery_albums_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_gallery_albums_event ON public.gallery_albums USING btree (event_id);


--
-- Name: idx_gallery_albums_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_gallery_albums_year ON public.gallery_albums USING btree (year);


--
-- Name: idx_gallery_photos_album; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_gallery_photos_album ON public.gallery_photos USING btree (album_id);


--
-- Name: idx_labarthis_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_labarthis_event ON public.event_labarthis USING btree (event_id);


--
-- Name: idx_member_children_member; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_member_children_member ON public.member_children USING btree (member_id);


--
-- Name: idx_refresh_tokens_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_tokens_hash ON public.refresh_tokens USING btree (token_hash);


--
-- Name: idx_refresh_tokens_member; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_tokens_member ON public.refresh_tokens USING btree (member_id);


--
-- Name: idx_vibhag_heads_member; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vibhag_heads_member ON public.vibhag_heads USING btree (member_id);


--
-- Name: idx_vibhag_heads_vibhag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vibhag_heads_vibhag ON public.vibhag_heads USING btree (vibhag_type);


--
-- Name: ads ads_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ads
    ADD CONSTRAINT ads_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.members(id);


--
-- Name: audit_logs audit_logs_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.members(id);


--
-- Name: event_assignments event_assignments_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_assignments
    ADD CONSTRAINT event_assignments_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.members(id);


--
-- Name: event_assignments event_assignments_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_assignments
    ADD CONSTRAINT event_assignments_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: event_assignments event_assignments_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_assignments
    ADD CONSTRAINT event_assignments_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(id) ON DELETE CASCADE;


--
-- Name: event_labarthis event_labarthis_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_labarthis
    ADD CONSTRAINT event_labarthis_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.members(id);


--
-- Name: event_labarthis event_labarthis_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_labarthis
    ADD CONSTRAINT event_labarthis_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: events events_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.members(id);


--
-- Name: events events_members_locked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_members_locked_by_fkey FOREIGN KEY (members_locked_by) REFERENCES public.members(id);


--
-- Name: events events_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.members(id);


--
-- Name: events fk_events_vibhag; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT fk_events_vibhag FOREIGN KEY (vibhag_type) REFERENCES public.vibhags(type);


--
-- Name: gallery_albums gallery_albums_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_albums
    ADD CONSTRAINT gallery_albums_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.members(id);


--
-- Name: gallery_albums gallery_albums_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_albums
    ADD CONSTRAINT gallery_albums_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE SET NULL;


--
-- Name: gallery_photos gallery_photos_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_photos
    ADD CONSTRAINT gallery_photos_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.gallery_albums(id) ON DELETE CASCADE;


--
-- Name: gallery_photos gallery_photos_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery_photos
    ADD CONSTRAINT gallery_photos_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.members(id);


--
-- Name: member_children member_children_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member_children
    ADD CONSTRAINT member_children_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: member_profiles member_profiles_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.member_profiles
    ADD CONSTRAINT member_profiles_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: refresh_tokens refresh_tokens_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(id);


--
-- Name: vibhag_heads vibhag_heads_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vibhag_heads
    ADD CONSTRAINT vibhag_heads_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.members(id);


--
-- Name: vibhag_heads vibhag_heads_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vibhag_heads
    ADD CONSTRAINT vibhag_heads_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(id) ON DELETE CASCADE;


--
-- Name: vibhag_heads vibhag_heads_vibhag_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vibhag_heads
    ADD CONSTRAINT vibhag_heads_vibhag_type_fkey FOREIGN KEY (vibhag_type) REFERENCES public.vibhags(type) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict GeH7a0kbwNuaMChB2av5um5hfkdoubu9iLviCA3FmZVq19WqIhg9gLjWbFP0c9y

