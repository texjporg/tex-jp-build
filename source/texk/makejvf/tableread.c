#include <kpathsea/config.h>
#include "makejvf.h"

#include <stdio.h>
#include <stdlib.h>

int usertable_replace_max,usertable_move_max;
struct USERTABLE_REPLACE usertable_replace[1024];
struct USERTABLE_MOVE usertable_move[1024];

void get_usertable(char *name)
{
	FILE *fp;
	char *tok,*endptr,buf[BUF_SIZE];

	usertable_replace_max = 0;
	usertable_move_max = 0;
	fp = fopen(name,"r");
	if (fp == NULL) {
		fprintf(stderr,"Cannot find %s!\n",name);
		exit(1);
	}
	for (int l = 0; l < MAX_TABLE;) {
		if (fgets(buf, BUF_SIZE, fp) == NULL) break;
		char *tok = strtok(buf, "\t");
		if (!strcmp(tok, "REPLACE")) {
			usertable_replace[usertable_replace_max].codepoint = strtol(strtok(NULL, "\t\n"), &endptr, 16);
			if (*endptr != '\0') goto taberr;
			usertable_replace[usertable_replace_max].newcodepoint = strtol(strtok(NULL, "\t\n"), &endptr, 16);
			if (*endptr != '\0') goto taberr;
			if (strtok(NULL, "\t\n") != NULL) goto taberr;
			usertable_replace_max++;
			goto rep;
		}
		if (!strcmp(tok, "MOVE")) {
			usertable_move[usertable_move_max].codepoint = strtol(strtok(NULL, "\t\n"), &endptr, 16);
			if (*endptr != '\0') goto taberr;
			usertable_move[usertable_move_max].moveright = strtod(strtok(NULL, "\t\n"), &endptr);
			if (*endptr != '\0') goto taberr;
			usertable_move[usertable_move_max].movedown = strtod(strtok(NULL, "\t\n"), &endptr);
			if (*endptr != '\0') goto taberr;
			if (strtok(NULL, "\t\n") != NULL) goto taberr;
			usertable_move_max++;
			goto rep;
		}
		fprintf(stderr, "Unknown setting %s found in %s (line %d)!\n", tok, name, l+1);
		exit(1);
taberr:
		fprintf(stderr, "Error in user-defined table file %s (line %d)!\n", name, l+1);
		exit(1);
rep:
		l++;
	}
	if (fgets(buf, BUF_SIZE, fp) != NULL) {
		fprintf(stderr, "User-defined table in %s is too large!\n", name);
		exit(1);
	}
	fclose(fp);
}
