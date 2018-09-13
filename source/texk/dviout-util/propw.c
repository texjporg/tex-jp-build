/*
 *     	Generate TeX PL file for Japanese Proportional Fonts
 *				Originally written by  SHIMA, Nov. 2000
 *
 */

#include <stdio.h>
#include <stdlib.h>

#ifdef UNIX
#include <unistd.h>
#include <string.h>
#else
#ifdef WIN32
#include <windows.h>
#define	SJIS	1	/* Use SHIFT JIS (otherwise EUC) */
#define	USETTF
#endif
#endif

#include <config.h>

#define	MAX_BSIZE	0x20000
#define	LBSIZE		0x1000
#define	MAX_LINE	0x2000
#define	MAXCTYPE	0x1000
#define	NSIZE		0x80

#if	SJIS
#define	JKUTEN	0x8141
#define	JKAKKO	0x8165
#define	JDASH	0x815C
#define	J3DOT	0x8163
#define	JCHUT	0x8145
#define	JBEYOND	0xEAA5
#else
#define	JKUTEN	(0x2122|0x8080)
#define	JKAKKO	(0x2146|0x8080)
#define	JDASH	(0x213D|0x8080)
#define	J3DOT	(0x2144|0x8080)
#define	JCHUT	(0x2125|0x8080)
#define	JBEYOND	(0x7921|0x8080)
#endif

#define	KASIZE	22
#define	KUSIZE	4
#define	KKUTEN	(JKUTEN+KUSIZE-1)
#define	KKAKKO	(JKAKKO+KASIZE-1)
#define	J2DOT	(J3DOT+1)
#define	KCHUT	(JCHUT+2)

int	START	= 6;			/* ltop of new label */
int DENOM	= 256;			/* unit of zenkaku	*/
int	f_tate	= 0;			/* tate mode ?		*/
int f_kuten	= 0;			/* special kutten	*/
int	n_kuten = 0;			/* #special kutten	*/
int f_pl	= 0;			/* generate pl?		*/
int step	= 1;			/* minimal unit		*/
int	f_verb	= 0;			/* verbose			*/
int	f_beyond = 0;			/* large JIS code	*/
int f_make	= 0;			/* make if not-exist */

int mode	= 0;			/* mode in process	*/
int	f_denom	= 0;			/* define ZENKAKU?	*/
int	f_jfm	= 0;			/* make jfm file	*/

int	kuten[KUSIZE];			/* width of Kuten	*/
int	kakko[KASIZE];			/* width of Kakko	*/

double	ZW	= 0.962216;		/* tfm width		*/
double	ZH	= 0.916443;		/* height+depth		*/
double	ZD	= 0.138855;		/* depth in yoko	*/

double	ZWS = 0.638972;		/* MS P space		*/

double DS	= 10.0;			/* designe size		*/
double STRT	= 0.091641;		/* stretch			*/
double ESPC	= 0.229101;		/* extra space 		*/
double ESTR	= 0.183283;		/* extra stretch	*/
double ESHR	= 0.114551;		/* extra shrink		*/
double AD	= 0;			/* plus glue		*/

unsigned int CS = 0;		/* check sum		*/
int f_cs;			/* default check sum	*/
int	REFER = 16;	/* This should be even an non-negative integer  <= 20
					Hiraki-Kakko of code  JKUTEN+REFER  is considered to be 
					a standard Yakumono	*/

int f_badpara = 0;			/* ignore Bad Parameter */
int f_para = 0;	 /* 0: no-para  1: read-para  2: out-para  3: out-read */


char family[NSIZE] = "UNKNOWN";	/* FAMILY name	*/
char namettf[NSIZE];			/* name of TrueType Font */ 
char namejfm[NSIZE];			/* name of pl file		*/
char outfile[0x200];
char work[NSIZE];

#ifdef	USETTF
int	f_font	= 0;			/* Font indicated	*/
char face[NSIZE];			/* facename */
#endif

char buf[LBSIZE];			/* one line buffer	*/
char word[MAXCTYPE];		/* character type	*/

char info[MAX_BSIZE];		/* buffer to keep lines */
char *line[MAX_LINE];		/* pointer of lines	*/

int	pt_info;				/* pointer of buffer info[] */
int	pt_line;				/* current line		*/
int	mx_line;				/* last line		*/

FILE *fo; // = stdout;
FILE *fe; // = stderr;

/****************************************************/
#define	ZW2		(ZW/2)
#define	ZW4		(ZW/4)
#define	ZH2		(ZH/2)
#define	ZHH		(ZH-ZD)

#define	NORMAL		(f_pl&1)
#define	TSUME		(f_pl&8)
#define	oct(x)		(((x)>>6)*100+(((x)>>3)&7)*10+((x)&7))
#define	issjis1(x)	((x)>=0x81&&(x)<=0xfc&&((x)<=0x9f||(x)>=0xe0))

int option(char *para);
void HeaderOut(FILE *fh, int mode);
void Exit(int code);

void msg(void)
{
	printf(
	"\t\tpropw: support to make a PL/JFM file for pTeX\n"
	"\t\t    Originally written by SHIMA, Nov. 2000\n"
	"\t\t    Ver.%s (%s)\n\n", VERSION, TL_VERSION);
	printf(
	"Usage : propw [-trquv"
#ifdef	USETTF
	"#"
#endif
	"] [-p[t][m|n]] [-<k>=<value>] [-s<step>] [-d<den>]\n"
	"          [-l<num>] [-o=<ofile>] [@<pfile>] ["
#ifdef	USETTF
	"#<TrueType_font_name>|"
#endif
	"<file>]\n\n"
	"-t: tate  -r: over 7426(JIS)  -q: square  -u: update  -v: verbose"
#ifdef	USETTF
	"  -#: Font"
#endif
	"\n"
	"-p    : make pl (-pm: MS type, -pn: normal type, -pt: Glue-Tsume)\n"
	"<k>   : zw(width), zh(height+depth), zd(depth), ds(design size), cs(checksum)\n"
	"        st(stretch), ep(ex space), et(ex stretch), eh(ex shrink), fm(family)\n"
	"        ad(glue plus), kn(Kakko)\n"
	"<num> : the first label   (default:6)\n"
	"<step>: step of tfm-width (default:1)\n"
	"<den> : width of zenkaku  (default:256)\n"
	"<ofile>: <ofile> is a file to be output (Make JFM if its extension is \".tfm\")\n"
	"<pfile>: <pfile> is a file where paramaters are written\n"
	"<file> : <tfm-width> [<tsume-width>] <a character>   is in each line.\n"
	"         Analyse lines if they are not sorted by <tfm-width>.\n"
	"         The line whose top is not a figure is ignored except for\n"
	"           #Font: <TrueType_font_name>   (an optional line)\n"
	"           #<para>: Same as -<para> in the command line\n"
#ifdef	USETTF
	"Example: propw -o=msptmin.pl \"-fm=MS P MINCHOU\" \"#@ＭＳ Ｐ明朝\"\n"
#endif
	);
	Exit(1);
}

void Exit(int code)
{
	fclose(fo);
	fclose(fe);
	if(code && outfile[0])
		unlink(outfile);
	exit(code);
}

char *glue[2] = 
{
	"   (GLUE O %d R 0.0 R %f R 0.0)\n", 
	"   (GLUE O %d R %f R 0.0 R %f)\n"
};

char aglue[0x30];

char *STOPLABEL = "   (STOP)\n   (LABEL O %d)\n";

char *LABEL = 
//	"(COMMENT THIS IS A KANJI FORMAT FILE)\n"
	"(FAMILY %s)\n"
	"%s"
	"(FACE F MRR)\n"
	"(CODINGSCHEME TEX KANJI TEXT)\n"
	"(DESIGNSIZE R %f)\n"
//	"(COMMENT DESIGNSIZE IS IN POINTS)\n"
//	"(COMMENT OTHER SIZES ARE MULTIPLES OF DESIGNSIZE)\n"
	"%s"
	"(SEVENBITSAFEFLAG TRUE)\n"
	"(FONTDIMEN\n"
	"   (SLANT R 0.0)\n"
	"   (SPACE R 0.0)\n"
	"   (STRETCH R %f)\n"
	"   (SHRINK R 0.0)\n"
	"   (XHEIGHT R %f)\n"
	"   (QUAD R %f)\n"
	"   (EXTRASPACE R %f)\n"
	"   (EXTRASTRETCH R %f)\n"
	"   (EXTRASHRINK R %f)\n"
	"   )\n"
	"(GLUEKERN\n";

void glue0(void)
{
	fprintf(fo, glue[NORMAL], 1, ZW2, ZW2);
	fprintf(fo, glue[NORMAL], 3, ZW4, ZW4);
}

void glue1(void)
{
	fprintf(fo, STOPLABEL, 1);
	fprintf(fo, glue[NORMAL], 3, ZW4, ZW4);
	fprintf(fo, STOPLABEL, 2);
}

void glue2(void)
{
	int label;
	double ff;

	for(label = 1; label <= 5; label+=2){
		ff = (label==3)?ZW4:ZW2;
		fprintf(fo, glue[NORMAL], label, ff, ff);
	}
	fprintf(fo, STOPLABEL, 3);
}

void glue3(void)
{
	int label;
	double ff1, ff2;

	ff2 = ZW4;
	for(label = 1; label <= 5 + n_kuten; label++){
		ff1 = (label==3)?ZW2:ZW4;
		fprintf(fo, glue[NORMAL], label, ff1, ff2);
	}
	fprintf(fo, STOPLABEL, 4);
	for(label = 6; label < 6+n_kuten; label++)
		fprintf(fo, "   (LABEL O %d)\n", oct(label));
}

void glue4(void)
{
	if(NORMAL){
		fprintf(fo, glue[1], 1, ZW2, 0.0);
		fprintf(fo, glue[1], 3, ZW2+ZW4, ZW4);
		fprintf(fo, glue[1], 5, ZW2, 0.0);
	}else{
		fprintf(fo, glue[0], 1, ZW-ZWS);
		fprintf(fo, glue[0], 3, ZW-ZWS+ZW4);
		fprintf(fo, glue[0], 5, ZW-ZWS);
	}
	fprintf(fo, STOPLABEL, 5);
	fprintf(fo ,glue[NORMAL], 1, ZW2, ZW2);
	fprintf(fo, glue[NORMAL], 3, ZW4, ZW4);
 	fprintf(fo, "   (KRN O 5 R 0.0)\n   (STOP)\n   )\n");
}

char *CHAR_TYPE = 
	"(CHARSINTYPE O 1\n"
	"   ‘ “ （ 〔 ［ ｛ 〈 《 「 『 【 \n"
	"   )\n"
	"(CHARSINTYPE O 2\n"
	"   、 ， ’ ” ） 〕 ］ ｝ 〉 》 」 』 】 \n"
	"   )\n"
	"(CHARSINTYPE O 3\n"
	"   ・ ： ； \n"
	"   )\n"
	"(CHARSINTYPE O 4\n"
	"   。 ． \n"
	"   )\n"
	"(CHARSINTYPE O 5\n"
	"   ― … ‥ \n"
	"   )\n";

char *MCHAR_TYPE1 = 
	"(CHARSINTYPE O 1\n"
	"   ";

char *MCHAR_TYPE2 = 
	"\n"
	"   )\n"
	"(CHARSINTYPE O 2\n"
	"   ";

char *MCHAR_TYPE3 =
	"\n"
	"   )\n"
	"(CHARSINTYPE O 3\n"
 	"   ・ %s\n"
 	"   )\n"
	"(CHARSINTYPE O 4\n"
	"   。 %s%s%s\n"
	"   )\n"
	"(CHARSINTYPE O 5\n"
 	"   ― … ‥ \n"
	"   )\n";

char *MADDCHAR = "： ；";

char *TYPE = 
	"(TYPE O %d\n"
	"   (CHARWD R %f)\n"
	"   (CHARHT R %f)\n"
	"   (CHARDP R %f)\n"
	"   )\n";


#ifdef USETTF
char *GetFontWidth(char *facename)
{
	static HFONT hFont;
	static HDC	hDC;
	static char selectfont[32];
	static int i, j, k, pt, f_cont;
	static MAT2 mat;
	static int out[] = {
		0x8d91,	0x8d91,		/* KUNI */
		0x8141, 0x817e,		/* Kigou Yakumono 1 */
		0x8180, 0x81ac,		/* Kigou Yakumono 2 */
		0x829f, 0x82f1,		/* Hira kana      */
		0x8340, 0x837e,		/* kata kana 1	  */
		0x8380, 0x8396,		/* kata kana 2	  */
   		0x824f, 0x8258,		/* Suuji	*/
		0x8260, 0x8279,		/* ABC		*/
    	0x8281, 0x829A,		/* abc		*/
    	0x839f, 0x83b6,		/* GREEK	*/
		0x83bf,	0x83d6,		/* greek	*/
		0x8440,	0x8460,		/* RUSSIA	*/
		0x8470, 0x847e,		/* russia 1	*/
		0x8480, 0x8491,		/* russia 2	*/
		0x81b8,	0x81bf,		/* Kigou 3	*/
		0x81c8,	0x81ce,		/* Kigou 4	*/
		0x81da,	0x81e8,		/* Kigou 5	*/
		0x81f0,	0x81f7,		/* Kigou 6	*/
		0x81fc,	0x81fc,		/* Kigou 7	*/
		0	  , 0
	};

	if(f_cont){
		if(f_cont == 1)
			goto rep;
		DeleteObject( hFont );
		return NULL;
	}
	f_cont = 1;
	mat.eM11.value = mat.eM22.value = 1;
	mat.eM12.value = mat.eM21.value = 0;

	hFont = CreateFont( -DENOM, // size
		0, 0, 0,
		0, // default weight, FW_DONTCARE, FW_NORMAL, FW_BOLD
		FALSE, // not italic
		FALSE, // not underline,
		FALSE, // not striked
		SHIFTJIS_CHARSET,
		OUT_TT_ONLY_PRECIS,
		CLIP_DEFAULT_PRECIS,
		PROOF_QUALITY,
		VARIABLE_PITCH, // FIXED_PITCH
		facename );

	if( hFont == NULL ){
		fprintf(fe,  "Cannot open the font %s.\n", facename);
		Exit(1);
	}

	hDC = CreateCompatibleDC( NULL );
	if( hDC == NULL )
	{
		fprintf(fe, "Cannot create memory device context.\n" );
		Exit( 1 );
	}
	SelectObject( hDC, hFont );
	GetTextFace( hDC, 32, selectfont );
	fprintf(fe,  "--- Selected font \"%s\" ---\n", selectfont );
	if(strcmp(selectfont, facename)){
		fprintf(fe,  "--- Not the required font \"%s\" ---\n", facename);
		Exit( 6 );
	}
	sprintf(buf, "#Font: \"%s\"", facename);
	for(k = 0; i = out[k++]; ){
		GLYPHMETRICS gm;
		int	charwidth;

		j = out[k++];
		for(pt = i; pt <= j; pt++){
			return buf;
rep:
//			charwidth=0;
//			GetCharWidth32( hDC, pt, pt, &charwidth );
			gm.gmCellIncX = gm.gmCellIncY = 0;
    		GetGlyphOutline( hDC, pt, GGO_BITMAP,
				&gm, 0, NULL, &mat);
			charwidth =gm.gmCellIncX;
			sprintf(buf, "%03d %c%c", charwidth, pt>>8, pt & 0xff);
		}
	}
	f_cont++;
	return buf;
}

void ReadMap(FILE *fp)
{
	FILE *fh;
	int fdel, code;
	int	f_skip = 0;
	char *s, *t;

	f_badpara = 1;
	while(fgets(buf, 0x1000, fp) != NULL){
		if(f_skip){									/* skip */
			if(!strncmp(buf, "%endskip", 8)
			&& ((unsigned char *)buf)[8] <= ' ')
				f_skip = 0;
			continue;
		}
		if(buf[0] == '%'){
			if(!strncmp(buf,"%skip", 5)
			&& ((unsigned char *)buf)[5] <= ' ')
				f_skip = 1;
			continue;
		}
		if(buf[0] == '#' && ((unsigned char *)buf)[1] > ' '){	/* parameter */
			option(buf+1);
			f_para |= 1;
			continue;
		}
		t = buf;
		s = &namejfm[0];
		if(!*t || *t == '\n' || *t == ';' || *t == '#')
			continue;
		if(*t == 0x22){
			fdel = 1;
			if(!*++t)
				continue;
		}else
			fdel = 0;
		while(1){
			if((*s++ = *t++) == '/'){
				fprintf(stderr, "Cannot support (attributes): %s\n", buf);
				continue;
			}
			if(s >= namejfm + NSIZE - 4)
				continue;
			if( !fdel ) 	/* not starting by '"' */
				if( *t <= ' ' ) break; /* less than ' ', including TAB. */
			else if( *t == '\"' )
			{ /* starting from '"' and current == '"', stop here. */
				t++; /* To ignore '"', step t one more. */
				break;
			}
			else if( !*t ) /* starting from '"' and current == NULL. */
				break;
		}
		*s++ = 0;

		/* skip blank chars. */
		while(*t == ' ' || *t == '\t') t++;
		if(!*t || *t == '\n' || *t == ';' || *t == '#' || *t == '%')
			continue;

		/* 2nd step. copying Windows-Font name. */
		s = &namettf[0];
		if(*t == '\"'){
			fdel = 1;
			if(!*++t)
				continue;
		}else
			fdel = 0;
		while(1){
			code = *s++ = *t++;
			if(issjis1(code) && *t)
				*s++ = *t++;
			if(s >= namettf + NSIZE - 4)
				continue;
			if(!fdel){
				if(*t <= ' ')
					break;
			}
			else if(!*t)
				continue;
			else if(*t == '\"'){
				t++;
				break;
			}
		}
		*s = 0;
		if((f_para & 1) != 0){
			fh = fopen("$.par", "w");
			if(fh == NULL){
				fprintf(stderr, "Cannot open parameter file $.par\n");
				exit(1);
			}
			HeaderOut(fh, 0);
			fclose(fh);
			f_para = 2;
		}
		sprintf(buf, 
			"propw -#%c -o=%s.tfm @$.par \"%s\"", 
			f_make?'u':' ',
			namejfm, namettf);
		system(buf);
	}
	if(f_para >= 2)
		unlink("$.par");
	exit(0);
}
#endif

double	Myatof(char *para)
{
	while(*para && (*para == ' ' || *para == '\t'))
		para++;
	if(*para == '=')
		para++;
	while(*para && (*para == ' ' || *para == '\t'))
		para++;
	return atof(para);
}

int	Myatoi(char *para)
{
	while(*para && (*para == ' ' || *para == '\t'))
		para++;
	if(*para == '=')
		para++;
	while(*para && (*para == ' ' || *para == '\t'))
		para++;
	return atoi(para);
}

void BadPara(char *s)
{
	if(f_badpara)
		return;
	fprintf(stderr, "Bad Parameter -%s\n", s);
	exit(1);
}

int SetKuten(void)
{
	n_kuten = 0;

	if(!kuten[1])
		return 0;

	f_kuten = 2;
	if(kuten[0] != kuten[1]){
		n_kuten++;
		f_kuten |= 1;
	}
	if(kuten[2] != kuten[0]){
		n_kuten++;
		f_kuten |= 4;
	}
	if(kuten[3] != kuten[2]){
		f_kuten |= 8;
		n_kuten++;
	}
	return
		kuten[1];
}

int option(char *para)
{
	char *s, *t;
	int len, val;

	t = para;

rep:
	switch(*para++){

		case 't':
			f_tate = 1;
			goto rep;

		case 'r':
			f_beyond = 1;
			goto rep;

		case 'v':
			f_verb = 3;
			goto rep;

		case 'u':
			f_make = 1;
			goto rep;

#ifdef	USETTF
		case '#':
			f_font = 1;
			goto rep;
#endif

		case 'x':
			if(*para > ' ')
				goto er;
			if(f_para >= 2)
				unlink("$.par");
			fputs(para, stderr);
			exit( 2 );

		case 'F':
			if(!strncmp(para, "ONT: ", 5)){
				para += 5;
				while(*para && *para <= ' ')
					para++;
				if(*para++ != '\"')
					goto er;
				strncpy(namettf, para, NSIZE-1);
				len = strlen(namettf);
				while(len > 0 && namettf[len] != '\"')
					len--;
				if(len){
					namettf[len] = 0;
					break;
				}
			}
			goto er;

		case 'q':
			ZD = (ZH = ZW)*0.151515;
			ZWS = ZW*170/256;
			STRT = ZW*0.1;
			ESHR = (ESPC = ZW/4)/2;
			ESTR = ZW/5;
			goto rep;

		case 'k':
			switch(*para){
				case 'n':
					REFER = (Myatoi(para+1)-1)*2;
					if(REFER < 0 && REFER >= KASIZE)
						goto er;
					for(len = val = 0; len < KASIZE; len += 2){
						if(kakko[len] != 0){
							val = kakko[len];
							kakko[len] = 0;
						}
					}
					if(val > 0)
						kakko[REFER] = val;
					for(val = 0, len = 1; len < KASIZE ; len += 2){
						if(kakko[len] != 0){
							val = kakko[len];
							kakko[len] = 0;
						}
					}
					if(val > 0)
						kakko[REFER+1] = val;
					break;

				case 'l':
					kakko[REFER] = Myatoi(para+1);
					break;

				case 'r':
					kakko[REFER+1] = Myatoi(para+1);
					break;

				case 'a':
				case 'b':
				case 'c':
				case 'd':
					kuten[*para - 'a'] = Myatoi(para+1);
					SetKuten();
					break;

				default:
er:					BadPara(t);
					break;
			}
			break;

		case 'a':
			if(*para == 'd')
				AD = Myatof(para+1);
			break;

		case 'c':
			if(*para== 's'){
				if(para[1] == '-')
					f_cs = 1;
				else
					CS = Myatoi(para+1);
			}
			break;

		case 'l':
			START = Myatoi(para);
			break;

		case 's':
			if(*para == 't'){
				STRT = Myatof(para+1);
				break;
			}
			step = Myatoi(para);
			if(step < 1)
				BadPara(t);
			break;

		case 'd':
			if(*para == 's'){
				DS = Myatof(para+1);
				break;
			}
			f_denom = 1;
			DENOM = Myatoi(para);
			if(DENOM < 2)
				msg();
			break;

		case 'e':
			switch(*para){
				case 'p':
					ESPC = Myatof(para+1);
					break;
				case 't':
					ESTR = Myatof(para+1);
					break;
				case 'h':
					ESHR = Myatof(para+1);
					break;
				BadPara(t);
			}
			break;

		case 'p':
			f_pl = 1;
			if(*para == 'm')
				f_pl  = 6;
			else if(*para == 'n')
				f_pl |= 5;
			else if(*para == 't'){
				f_pl = 9;
				fprintf(fe, "-pt is not supported yet!\n");
				Exit(8);
			}
			mode = -1;
			START = 6;
			break;

		case 'z':
		  	switch(*para){
				case 'w':
					ZW = Myatof(para+1);
					break;
				case 'h':
					ZH = Myatof(para+1);
					break;
				case 'd':
					ZD = Myatof(para+1);
					break;
				default:
					BadPara(t);
		  	}
			break;

		case 'f':
			if(*para == 'm' && 
			  (para[1] == ' ' || para[1] == '\t' || para[1] == '=')){
				para += 2;
				s = &family[0];
				if(*para && !(*para & 0x80) && *para <= ' ')
					para++;
				for(len = 0; len < NSIZE-1; ){
					if(!(*para & 0x80) && *para <= '\n')
						break;
					s[len++] = *para++;
				}
				s[len] = 0;
			}
			break;

		case 'o':
			if(*para == '=' && fo == stdout){
				strncpy(outfile, para+1, 0x200-1);
				f_jfm = strlen(outfile);
				while(f_jfm-- > 0
				  && ((unsigned char *)outfile)[f_jfm] <= ' ');
				outfile[f_jfm+1] = 0;
				if(!f_make && !access(outfile, 0)){
					fprintf(stderr, 
				"-- %s exists! (Use the option -u to overwrite it) --\n", 
						outfile);
					exit( 8 );
				}
				f_jfm -= 3;
				if(f_jfm > 0){
					if(!strcmp(outfile+f_jfm, ".tfm"))
						strcpy(outfile+f_jfm, ".pl");
					else if(!strcmp(outfile+f_jfm, ".pl1"))
						f_jfm = -1;
					else if(!strcmp(outfile+f_jfm, ".pl2"))
						f_jfm = -2;
					else
						f_jfm = 0;
				}else
					f_jfm = 0;
			   	fo = fopen(outfile, "w");
				if(fo == NULL){
					fprintf(fe, "Cannot open %s\n", para+2);
					Exit(4);
				}
				f_verb |= 1;
				fe = stdout;
			}
			break;

		case  0:
		case ' ':
		case '\t':
		case '\n':
			break;

		default:
			BadPara(t);
	}
	return 1;
}

void HeaderOut(FILE *fh, int mode)
{
	int	len = strlen(outfile) - 4;

	if(len < 0)
		len = 0;

	fprintf(fh, "--- Header ---\n");
	outfile[len] = 0;
	if(mode)
		fprintf(fh, "%c#co=%s.tfm\n", '%', outfile);
	outfile[len] = '.';

	if(mode == 2)
		fprintf(fh, "#FONT: \"%s\"\n#p%c\n", namettf, NORMAL?'n':'m');
	if(strcmp(family, "UNKNOWN"))
		fprintf(fh, "#fm=%s\n", family);
	fprintf(fh, "#ds %f\n#zw %f\n#zh %f\n", DS, ZW, ZH);
	if(!f_tate)
		fprintf(fh, "#zd %f\n", ZD);
	fprintf(fh, "#st %f\n#ep %f\n#et %f\n#eh %f\n", STRT,  ESPC, ESTR, ESHR);
	if(AD != 0)
		fprintf(fh, "#ad %f\n", AD);
	if(f_cs)
		fprintf(fh, "#cs-\n");
	else if(CS == 0)
		fprintf(fh, "%c#cs 0.0\n", '%');
	else
		fprintf(fh, "#cs %u\n", CS);
	if(mode == 2)
		fprintf(fh, "#d  %d\n#s  %d\n--- YAKUMONO ---\n", DENOM, step);
	if(mode == 1 || !NORMAL)
		fprintf(fh, "#kn %d %c%c\n", REFER/2 + 1, 
			(JKAKKO+REFER)>>8, (JKAKKO+REFER)&0xff);
	if(mode == 2 && !NORMAL){
			fprintf(fh, "#kl %d", kakko[REFER]);
			for(len = JKAKKO; len <= KKAKKO; len += 2)
				if(kakko[len - JKAKKO] <= 0 || len == (JKAKKO+REFER))
					fprintf(fh, " %c%c", len>>8, len & 0xff);
			fprintf(fh, "\n#kr %d", kakko[REFER+1]);
			for(len = JKAKKO+1; len <= KKAKKO; len += 2)
				if(kakko[len - JKAKKO] <= 0 || len == (JKAKKO+REFER+1))
					fprintf(fh, " %c%c", len>>8, len & 0xff);
			fprintf(fh, "\n");
			for(len = 0; len < KUSIZE; len++)
				fprintf(fh, "#k%c %d %c%c\n",
					'a'+len, kuten[len], (JKUTEN+len)>>8, (JKUTEN+len)&0xff);
	}
    if(mode)
		fprintf(fh, "--- Contents ---\n");
}

char *myfgets(char *buf, int size, FILE *fp, int keep)
{
	static int f_keep;
	int i, j, k, ch;
	char *pt;

	if(f_keep <= 0){ 
#ifdef	USETTF
		if(face[0]){
			pt = GetFontWidth(face);
			if(pt != NULL){
				if(f_jfm == -1){
					if(!f_keep){
						HeaderOut(fo, 1);
						f_keep = -1;
					}
					fprintf(fo, "%s\n", buf);
				}
				if(f_verb & 2)
					fprintf(fe, "%s\n", buf);
			}else if(f_jfm == -1){
				fclose(fo);
				fprintf(stderr, "--- done ---\n");
				exit(0);
			}
		}else
#endif
		pt = fgets(buf, size, fp);
		if(pt == NULL){
			if(fp != NULL
#ifdef	USETTF
			  && !face[0]
#endif
			)
				fclose(fp);
			if(keep)
				f_keep = 1;
			return NULL;
		}
		if(atoi(buf) > 1){
			if(keep){
				j = 0;
				while(buf[j] != 0 && !(buf[j] & 0x80))
					j++;
				ch = (unsigned char)(buf[j]);
				ch = ch*256 + (unsigned char)buf[j+1];
				if(ch < JBEYOND || f_beyond){
					size = strlen(buf) + 1;
					if(size + pt_info < MAX_BSIZE && mx_line < MAX_LINE-1){
						strcpy(info + pt_info, buf);
						line[mx_line++] = info + pt_info;
						pt_info += size;
					}
				}
			}
		}else if(!strncmp(buf, "#Font: ", 7)){	/* font name definition */
			for(i = 7; buf[i] == ' ' || buf[i] == '\t'; i++);
			j = 0;
			if(buf[i] == '"'){
				i++;
				j = 1;
			}
			if(buf[i] == '@')
				f_tate = 1;
			for(k = 0; k < NSIZE-2; ){
				if(((ch = buf[i]) < ' ' && !(ch & 0x80)) || (j && ch == '"'))
					break;
				ch = work[k++] = buf[i++];
#if	SJIS
				if(issjis1(ch))
					work[k++] = buf[i++];
#endif
			}
			work[k] = 0;
			if(!namettf[0]){
				strcpy(namettf, work);
				fprintf(fe, "--- Making PL for \"%s\" ---\n", work);
			}else if(strcmp(work, namettf)){
				fprintf(fe, "Multiple definition of fonts %s", buf);
				Exit(2);
			}
		}else{
			for(i = 0; buf[i] == ' ' || buf[i] == '\t'; i++);
			if(buf[i] == '#')
				option(buf+i+1);
		}
		return pt;
	}else{
		if(pt_line < mx_line && keep){
			strcpy(buf, line[pt_line++]);
			return buf;
		}else
			return NULL;
	}
}

int lsp(char *s)
{
	while((*s >= 0 && *s <= '9') || *s == ' ' || *s == '\t')
		s++;
	return (!*s || !s[1])?0:atoi(s+2);
}

int mycomp(char *s1, char *s2, int w, int n)
{
	int i, j;

	i = atoi(s1)/w;
	j = atoi(s2)/w;
	if(i != j)
		return i-j;
	return lsp(s1)/n - lsp(s2)/2;
}

void mysort(int w, int n)
{
	int i, j;
	char *pt;

	for(i = 1; i < mx_line; i++){
		pt = line[j = i];
		while(j-- > 0 && mycomp(line[j], line[j+1], w, n) > 0)
			line[j+1] = line[j];
		line[j+1] = pt;
	}
}

int GetCode(unsigned char *s)
{
	while(*s != 0 && !(*s & 0x80))
		s++;
	return *s*256 + s[1];
}

void CutNull(void)
{
	int i,j;

	for(i = j = 0; i < mx_line; i++){				/* Cut ZENKAKU etc */
		if(line[i][0] && atoi(line[i]) != DENOM)
			line[j++] = line[i];
	}
	mx_line = j;
}

void sortline(void)
{
	int i, j, num, w, wku, wh, fms, kpt, h[9], kpos[KASIZE];
	char *pt;

	if(!f_denom){
		for(i = 0; i < mx_line; i++){		/* define 全角幅 */
			num = GetCode((unsigned char *)(line[i]));
			if(num >= 0x889f){				/* 亜 */
				DENOM = atoi(line[i]);
				f_denom = 1;
				if(f_verb)
					fprintf(fe, "Zenkaku   = %d by %c%c(%04X)\n", DENOM, 
						num >> 8, num & 0xff, num);
				break;
			}
		}
	}

	if(TSUME)
		mysort(step, step/2+1);
	else for(i = 1; i < mx_line; i++){
		num = atoi(pt = line[j=i]);
		while(j-- > 0 && atoi(line[j]) > num)
			line[j+1] = line[j];
		line[j+1] = pt;
	}

	fms = 0;
	wku = DENOM*170/256 - 2;
	wh  = DENOM/2-1;
	kpt = 0;
	for(i = 0; i < 9; i++)
		h[i] = -1;
	for(i = 0; i < mx_line; i++){
		j = 0;
		while(line[i][j] != 0 && !(line[i][j] & 0x80))
			j++;
		num = (unsigned char)(line[i][j]);
		num = num*256 + (unsigned char)line[i][j+1];
		w = atoi(line[i]);
		if(num == JDASH || num == J3DOT || num == J2DOT)	/* da-sh */
			line[i][0] = 0;
		else if(num >= JCHUT && num <= KCHUT)				/* chu-ten */
			line[i][0] = 0; 
		else if(num >= JKAKKO && num <= KKAKKO){			/* kakko */
			kakko[num-JKAKKO] = w;
			kpos[num-JKAKKO] = i;
		}else if(num >= JKUTEN && num <= KKUTEN){			/* kuten */
			kuten[num-JKUTEN] = w;
			if(w == DENOM){
				fms = -1;
				if(f_verb & 2)
					fprintf(fe, "%c%c is ZENKAKU:%d/%d\n", 
						num>>8, num & 0xff, w, DENOM);
			}
			line[i][0] = 0;
		}
// 		else if(num >= 0x814a && num <= 0x814f)
//			h[num-0x814a] = i;
	}
	if(f_verb){
		fprintf(fe, "Kakko:");
		for(i = 0; i < KASIZE; i++){
			if(kakko[i] != 0){
				num = i + JKAKKO;
				fprintf(fe, "  %c%c=%3d", num>>8, num&0xff, kakko[i]);
			}
			if(i == 7 || i == 15)
				fprintf(fe,"\n      ");
			else if(i == 21)
				fprintf(fe,"\n");
		}
	}
	if(!fms
		&& kakko[REFER] > 1 && kakko[REFER] < DENOM-1
		&& kakko[REFER+1] > 1 && kakko[REFER+1] < DENOM-1){
		fms = 1;
		for(i = 0; i < KASIZE; i++){
			if(  kakko[i] >= kakko[REFER+(i&1)] - 1
			  && kakko[i] <= kakko[REFER+(i&1)] + 1){
				line[kpos[i]][0] = 0;
				if(i != REFER && i != REFER+1)
					kakko[i] = -1;				/* same width */
			}
		}
	}else if(f_pl == 6){				/* assme to be the fixed size */
		for(i = 0; i < KASIZE; i++){
			kakko[i] = -1;
			if(kakko[i] > 0)
				line[kpos[i]][0] = 0;
		}
		kakko[REFER] = kakko[REFER+1] = DENOM*170/256;
	}

	if(fms > 0 || f_pl == 6){
		f_pl = 2;								/* MS type */
		for(i = 0; i < KUSIZE; i++){
			if(kuten[i] >= kuten[1]-2 && kuten[i] <= kuten[1]+2)
			kuten[i] = kuten[1];
		}
		i = SetKuten();
		if(i)
			wku = i;
		if(f_verb)
			fprintf(fe, "Kuten:  、=%d  。=%d  ，=%d  ．=%d\n",
				kuten[0], kuten[1], kuten[2], kuten[3]);
		for(i = 0; i < 9; i++){
			if(h[i] >= 0)
				line[h[i]][0] = 0;
		}
		ZWS = ZW*wku/DENOM; /* kuten size */
	}else{
		f_pl = 1;									/* general type */
		for(i = 0; i < KASIZE; i++){
			if(kakko[i] > 0)
				line[kpos[i]][0] = 0;
		}
	}
	CutNull();
}

void myrewind(FILE *fp)
{
	pt_line = 0;
}

void main(int argc, char **argv)
{
	int i, j, k, num, pos, label, llabel;
	int	width, width0, s_width, lspc0, s_lspc;
	int f_end = 0;
	int f_sort = -1;
	double ff, ff1, ff2;
	FILE *fp;

	fo = stdout;
	fe = stderr;

	k = isatty(fileno(stdin))?1:0;
	for(i = 0; i < argc - k; i++){		/* read parameter file */
		if(!strcmp(argv[i], "-#"))
			k = 1;
		if(argv[i][0] != '@')
			continue;
		fp = fopen(argv[i]+1, "rt");
		if(fp == NULL){
			fprintf(fe, "Cannot open the parameter file %s\n", argv[i]+1);
			continue;
		}
		while(myfgets(buf, 0x1000, fp, 0) != NULL);
	}

	for(i = 1; i < argc; i++){			/* option parameters */
		if(argv[i][0] == '-' && !option(argv[i]+1))
			msg();
	}

// strcpy(face, "ＭＳ Ｐ明朝");
// goto ttf1;

#ifdef	USETTF
	if(f_font)
		goto ttf;
	if(argv[argc-1][0] == '#'){
ttf:	strncpy(face, 
			argv[argc-1]+((argv[argc-1][0]=='#')?1:0), 0x80);
// ttf1:
		if(!f_pl){
			mode = -1;
			START = 6;
			f_pl = 1;
		}
	}else
#endif
	{
		if(!isatty(fileno(stdout)))
			f_verb = 1;
		if(argc <= 1 || argv[argc-1][0] == '-'){
    		if(isatty(fileno(stdin)))
				msg();
			fp = stdin;						/* read from stdin */
		}else{								/* read from file */
			fp = fopen(argv[argc-1], "r");
			if(fp == NULL){
				fprintf(fe, "Cannot found %s\n", argv[argc-1]);
				Exit(3);
			}
#ifdef	USETTF
			if( (i = strlen(argv[argc-1]) - 4) > 0
			  && !strcmp(argv[argc-1]+i, ".map") )	/* read *.map */
				ReadMap(fp);
#endif
		}
	}

	if(AD){
		sprintf(aglue,"   (GLUE O %cd R %cf R %f R %cf)\n", 
			'%', '%', AD, '%');
		glue[1] = &aglue[0];
	}
	if(NORMAL)
		ZWS = ZW2;
	llabel = START;
	if(!TSUME && mode == 1)
		mode++;

rep:
	if(f_pl){
		if(mode == 0){
			char tmp[32], tmp2[50];

			if(f_cs)
				tmp2[0] = 0;					/* default checksum */
			else{
				tmp[i=31] = 0;
				j = CS/8;
				k = CS - ((unsigned int)j)*8;
				tmp[--i] = '0' + k;
				sprintf(tmp2, "(CHECKSUM O %s)\n", tmp+i);
			}
			while(j && --i >= 0){
				j = k/8;
				k -= j*8;
				tmp[i] = '0' + k;
				k = j;
			}

			fprintf(fo, LABEL, family, 
				f_tate?"(DIRECTION TATE)\n":"", 
				DS, tmp2, STRT, ZH, ZW, ESPC, ESTR, ESHR);

			for(label = 0; label < llabel; label++){
				if(label && label < START+n_kuten)
					continue;
				fprintf(fo, "   (LABEL O %d)\n", oct(label));
			}
			glue0();
		}else if(mode == 1){
m1:			glue1();

			for(label = 0; label < llabel; label++){
				if(label && label < START+n_kuten)
					continue;
				fprintf(fo, glue[NORMAL], oct(label), ZW2, ZW2);
			}
			glue2();

			for(label = 0; label < llabel; label++){
				if(label && label < START+n_kuten)
					continue;
				fprintf(fo, glue[NORMAL], oct(label), ZW4, ZW4);
			}
			glue3();

			for(label = 0; label < llabel; label++){
				if(label && label < START+n_kuten)
					continue;
				fprintf(fo, glue[NORMAL], oct(label), ZW-ZWS, 0.0);
			}
			glue4();

			if(NORMAL)
				fprintf(fo, CHAR_TYPE);
			else{
				fprintf(fo, MCHAR_TYPE1);
				for(i = JKAKKO; i <= KKAKKO; i += 2){
					if(kakko[i - JKAKKO] <= 0 || i == (JKAKKO+REFER))
						fprintf(fo, "%c%c ", i>>8, i & 0xff);
				}
				fprintf(fo, MCHAR_TYPE2);
				for(i = JKAKKO+1; i <= KKAKKO; i += 2){
					if(kakko[i - JKAKKO] <= 0 || i == (JKAKKO+REFER+1))
						fprintf(fo, "%c%c ", i>>8, i & 0xff);
				}
				fprintf(fo, MCHAR_TYPE3,
					(f_tate)?"":MADDCHAR,
					(f_kuten & 1)?	"":"、 ",
					(f_kuten & 5)?	"":"， ",
					(f_kuten & 13)?	"":"．"	);
				label = 6;
				if(f_kuten & 1){
					fprintf(fo, "(CHARSINTYPE O %d\n", oct(label));
					if(f_kuten & 4)
   						fprintf(fo, "   、 \n   )\n");
					else if(f_kuten & 8)
   						fprintf(fo, "   、 ， \n   )\n");
					else
   						fprintf(fo, "   、 ， ．\n   )\n");
					label++;
				}
				if(f_kuten & 4){
					fprintf(fo, "(CHARSINTYPE O %d\n", oct(label));
					if(f_kuten & 8)
   						fprintf(fo, "   ， \n   )\n");
					else
   						fprintf(fo, "   ， ．\n   )\n");
					label++;
				}
				if(f_kuten & 8){
					fprintf(fo, "(CHARSINTYPE O %d\n", oct(label));
   					fprintf(fo, "   ．\n   )\n");
				}
			}
		}else if(mode == 2){
			for(label = 0; label < START; label++){
				ff = (label >= 1&& label <= 4)?ZW2:ZW;
				if(!NORMAL){
					if(label == 4)
						ff = ZWS;
					else if(label == 1 || label == 2){
						ff = ZW*kakko[REFER+1-(label&1)]/DENOM;
						if(ff == 0)
							ff = ZW*170/256;
					}
				}
				if(!f_tate){
					ff1 = ZHH;
					ff2 = ZD;
				}else
					ff1 = ff2 = ZH2;
				fprintf(fo, TYPE, oct(label), ff, ff1, ff2);
			}
			if(f_kuten){
//				ff = ZW*kuten[1]/DENOM;
//				fprintf(fo, TYPE, oct(label), ff, ff1, ff2);
//				label++;
				if(f_kuten & 1){
					ff = ZW*kuten[0]/DENOM;
					fprintf(fo, TYPE, oct(label), ff, ff1, ff2);
					label++;
				}
				if(f_kuten & 4){
					ff = ZW*kuten[2]/DENOM;
					fprintf(fo, TYPE, oct(label), ff, ff1, ff2);
					label++;
				}
				if(f_kuten & 8){
					ff = ZW*kuten[3]/DENOM;
					fprintf(fo, TYPE, oct(label), ff, ff1, ff2);
				}
			}
		}
		if(!TSUME && mode == 0){
			mode++;
			goto m1;
		}
	}

	label = START + n_kuten;
	pos = 0;
	width = s_width = -1;
	s_lspc = -1;

	while(myfgets(buf, LBSIZE, fp, 1) != NULL){
		width0 = atoi(buf);
		if(width0 <= 0)
			continue;
		if(width0/step < s_width)
			f_sort = 1;
		if(TSUME){
			lspc0 = lsp(buf);
			if(lspc0/(step/2+1) < s_lspc)
				f_sort = 1;
		}
		if(width > 0 &&
		  (s_width != width0/step || (TSUME && lspc0/(step/2+1) != s_lspc))){
last:		k = oct(label);
			word[pos] = 0;
			if(f_pl && mode == 0){			/* TSUME */
				ff = ZW*(2*s_lspc + step/2)*(step/2+1)/(2*DENOM);
				fprintf(fo, glue[0], k, ff);
			}else if(mode == 1){
				fprintf(fo, "(CHARSINTYPE O %d\n", k);
   				fprintf(fo, "   %s\n   )\n", word);
			}else if(mode == 2){
				ff = ZW*width/DENOM;
				if(!f_tate){
					ff1 = ZHH;
					ff2 = ZD;
				}else
					ff1 = ff2 = ZH2;
				fprintf(fo, "(TYPE O %d\n", 			k);
				fprintf(fo, "   (CHARWD R %f)\n",		ff);
				fprintf(fo, "   (CHARHT R %f)\n",		ff1);
				fprintf(fo, "   (CHARDP R %f)\n   )\n",	ff2);
			}
			pos = 0;
			label++;
		}
		if(f_end){
			if(mode <= 1){
				f_end = 0;
				myrewind(fp);
				if(f_sort == 1){
					f_sort = 0;
					sortline();
					goto rep;
				}
				if(!TSUME && label > 83)	/* too many glue/kern index */
					step++;
				else if(TSUME & (label > 64)){
					step++;
					sortline();
				}else{					/* Cut data for the trivial case */
					if(  label ==  START + n_kuten + 1 && width == DENOM
					  && (!TSUME || !s_lspc) ){
						label--;
						mx_line = 0;
					}
					mode++;
					llabel = label;
					if(f_jfm == -2){
						HeaderOut(fo, 2);
						while(myfgets(buf, LBSIZE, fp, 1) != NULL){
							fputs(buf, fo);
							fputs("\n", fo);
						}
						fprintf(stderr, "--- done ---\n");
						exit(0);
					}
					if(f_sort == -1){
						for(i = 0; i < mx_line; i++){
							num = GetCode(line[i]);
							if(num >= JKUTEN && num <= KKUTEN){
								kuten[num-JKUTEN] = atoi(line[i]);
								line[i][0] = 0;
							}else if(num >= JKAKKO && num <= KKAKKO){
								if( num == (JKAKKO + REFER) ||
									num == (JKAKKO + REFER+1) ){
									if(!kakko[num-JKAKKO])
										kakko[num-JKAKKO] = atoi(line[i]);
									line[i][0] = 0;
								}else
									kakko[num-JKAKKO] = atoi(line[i]);
							}else if(num == JDASH
								|| num == J3DOT
								|| num == J2DOT
								|| (num >= JCHUT && num <= KCHUT) )
									line[i][0] = 0; 
						}
						CutNull();
						if(!NORMAL){
							if(kuten[1]){
								ZWS = ZW*kuten[1]/DENOM;	/* KUTEN size */
								if(!kuten[0])
									kuten[0] = kuten[1];
								if(!kuten[2])
									kuten[2] = kuten[0];
								if(!kuten[3])
									kuten[3] = kuten[2];
								SetKuten();
							}else{
								f_kuten = 0;
								ZWS = ZW*170/256;
							}
							if(!kakko[REFER])
								kakko[REFER] = DENOM/2;
							if(!kakko[REFER+1])
								kakko[REFER+1] = DENOM/2;
						}
						f_sort = 0;
					}
				}
				goto rep;
			}
			if(!f_pl){
				for(j = label, label = START+n_kuten; label < j; label++)
					fprintf(fo, "   (LABEL O %d)\n", oct(label));
				for(j = label, label = START+n_kuten; label < j; label++)
					fprintf(fo, "   (GLUE O %d R xx R yy R zz)\n", oct(label));
			}else
				fprintf(fe, 
					"--- Output %s type %s-kumi PL file (%d/%d) ---\n",
					NORMAL?"Normal":"MS Tsume", 
					f_tate?"TATE":"YOKO", step, DENOM);
			goto end;
		}
		width = width0;
		s_width = width/step;
		if(TSUME)
			s_lspc = lspc0/(step/2+1);
		for(k = 0; buf[k]; k++){
			if(buf[k] >= 0 && buf[k] <= '9')
				continue;
			if(buf[k] != ' ' && buf[k] != '\t')
				break;
		}
		if(pos >= MAXCTYPE - 4){
			fprintf(fe, "Too many characters in a character type\n");
			Exit(3);
		}
		word[pos++] = buf[k++];
		word[pos++] = buf[k++];
		word[pos++] = ' ';
	}
	if(pos){
		f_end = 1;
		goto last;
	}
	if(mode++ <= 1)
		goto rep;
end:
	if(f_jfm > 0 && f_pl){
		fclose(fo);
		sprintf(buf, "ppltotf -kanji=utf8 %s", outfile);
		outfile[f_jfm] = 0;
		fprintf(fe, "--- Translating %s.pl to %s.tfm by ppltotf ---\n",
			outfile, outfile);
		strcpy(outfile+f_jfm, ".tfm");
		unlink(outfile);
		system(buf);
		if(!access(outfile, 0)){
			fprintf(fe, "--- %s is made ---\n", outfile);
			strcpy(outfile+f_jfm, ".pl");
			unlink(outfile);
			outfile[f_jfm] = 0;
			fprintf(fe, "--- ptftopl %s  (<- the command to make the PL file) ---\n\n", outfile);
		}
		outfile[0] = 0;
	}
	Exit(0);
}
