#define BUF_SIZE 1024
#define MAX_TABLE 1024
extern char *vtfmname,*kanatfm,*jistfm,*ucsqtfm,*usertable;
extern int unit,zh,zw,jfm_id,rightamount;
extern int usertable_replace_max,usertable_move_max,usertable_charset_max;
extern int kanatume,chotai,baseshift,minute,hankana,fidzero,enhanced;
extern int pstfm_nt;
extern FILE *afp;
extern long ucs;
struct USERTABLE_REPLACE {
	int codepoint;
	int newcodepoint;
};
extern struct USERTABLE_REPLACE usertable_replace[1024];
struct USERTABLE_MOVE {
	int codepoint;
	double moveright;
	double movedown;
};
extern struct USERTABLE_MOVE usertable_move[1024];
struct USERTABLE_CHARSET {
	long min;
	long max;
};
extern struct USERTABLE_CHARSET usertable_charset[1024];

/* main.c */
void usage(void);

/* tfmread.c */
int jfmread(int kcode);
int tfmget(char *name);
int tfmidx(FILE *fp);

/* tool.c */
int mquad(unsigned char *p);
unsigned int upair(unsigned char *p);
int fquad(FILE *fp);
unsigned int ufpair(FILE *fp);
int fpair(FILE *fp);
int fputnum(int num, int byte, FILE *fp);
int numcount(int num);
int fputnum2(int num, FILE *fp);
int fputstr(char *str, int byte, FILE *fp);

/* write.c */
FILE *vfopen(char *name);
void writevf(int code, FILE *fp);
void writevfu(int code, FILE *fp);
void vfclose(FILE *fp);
void maketfm(char *name);

/* tableread.c */
void get_usertable(char *name);
