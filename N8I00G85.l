%{
#include<stdio.h>
#include<string.h>
#include<math.h>

struct course {
	char c_id[31];
	int creds;
	int grade;
};
struct student {
	char s_id[31];
	struct course courses[30]; //array of courses
	int num_courses;	
};
int curr_student,found1=0,found2=0,flag=0;
int num_stud = -1,num_records=0;
struct student s[1000];
int creds,grade,comments=0;
char course_id[31];
%}

%s START STUDID RECOPEN COURSEID CREDS GRADE RECCLOSE COMMENTS 
OPENBRACK \<
CLOSEBRACK \>

%%

"$" {flag = 0; BEGIN(START);}
"//" {comments++;BEGIN COMMENTS;}


<START>[A-Z]+[0-9]+ {			
			for(int i=0;i<num_stud;i++)
			{
				if(strcmp(s[i].s_id,yytext) == 0)
				{
					curr_student = i;
					found1=1;
				}
				else
				{
					continue;
				}
			}
			if(!found1)
			{
				curr_student = ++num_stud;
				strcpy(s[curr_student].s_id, yytext);
				s[curr_student].num_courses = 0;
			}
			found1=0;
			
			BEGIN(STUDID);}
<START>"\n" {}	
<START>" " {}
<START>. {BEGIN(INITIAL);}		

<STUDID>{OPENBRACK} {BEGIN(RECOPEN);}
<STUDID>. {}


<RECOPEN>[A-Z]+[0-9]+ {strcpy(course_id,yytext);
			BEGIN COURSEID;}
<RECOPEN>. {}
<RECOPEN>\n {BEGIN INITIAL;}

<COURSEID>[2-4] {creds = atoi(yytext);
			BEGIN CREDS;}
<COURSEID>{CLOSEBRACK} {BEGIN(STUDID);}
<COURSEID>. {}
<COURSEID>\n {BEGIN INITIAL;}


<CREDS>(A|A-|B|B-|C) {if(!strcmp(yytext,"A")){grade = 10;}
		       else if(!strcmp(yytext,"A-")){grade = 8;}
		       else if(!strcmp(yytext,"B")){grade = 6;}
		       else if(!strcmp(yytext,"B-")){grade = 4;}
		       else if(!strcmp(yytext,"C")){grade = 2;}
		       BEGIN GRADE;}
<CREDS>{CLOSEBRACK} {BEGIN(STUDID);}		   
<CREDS>. {}
<CREDS>\n {BEGIN INITIAL;}


<GRADE>{CLOSEBRACK} {
		for(int i=0;i<s[curr_student].num_courses;i++)
		{
			if(!strcmp(s[curr_student].courses[i].c_id,course_id))
			{
				s[curr_student].courses[i].creds = creds;
				s[curr_student].courses[i].grade = grade;
				found2 = 1;
				printf("%s%d\n",course_id,curr_student);
			}
			else
			{continue;}
		}
		if(!found2)
		{
			strcpy(s[curr_student].courses[s[curr_student].num_courses].c_id,course_id);
			s[curr_student].courses[s[curr_student].num_courses].creds = creds;
			s[curr_student].courses[s[curr_student].num_courses].grade = grade;
			s[curr_student].num_courses++;
		}
		found2 =0;
		
		if(!flag)
		{	
			num_records++;
			flag=1;
		}
		
		BEGIN RECCLOSE;}
<GRADE>. {}
<GRADE>\n {BEGIN INITIAL;}

		
<RECCLOSE>{OPENBRACK} {BEGIN RECOPEN;}
<RECCLOSE>'$' {BEGIN START;}
<RECCLOSE>"\n" {BEGIN INITIAL;}
<RECCLOSE>. {} 

<COMMENTS>. {}
<COMMENTS>\n {BEGIN INITIAL;}
. {}

%%

int main()
{
	
	FILE *fp = fopen("input.txt","r");
	char stud_search_id[31];
	int stud_found;
	fscanf(fp,"%s",stud_search_id);
	fclose(fp);
	yyin = fopen("data.txt","r");
	yylex();
	fclose(yyin);
	int sidExists = 0;
	for(int i=0;i<=num_stud;i++)
	{
		printf("%d,%s\n",i,s[i].s_id);
		if(!strcmp(s[i].s_id,stud_search_id))
		{	
			sidExists = 1;
			stud_found = i;
		}
		else
		{
			continue;
		}
	}
	if(sidExists == 0){
		int cg = 0;
		int numCoursesVar = 0;
		yyout = fopen("output.txt","w");
		fprintf(yyout,"@%d@%d@%d@%d#", num_records,comments,numCoursesVar,cg);
		return 0;
	}
	
	int cgpa=0;
	int total_credits=0;
	for(int i=0;i<s[stud_found].num_courses;i++)
	{
		printf("%s, %d, %d\n",s[stud_found].courses[i].c_id,s[stud_found].courses[i].creds,s[stud_found].courses[i].grade);
	}
	for(int i=0;i<s[stud_found].num_courses;i++)
	{
		cgpa += (s[stud_found].courses[i].creds)*(s[stud_found].courses[i].grade);
		total_credits += s[stud_found].courses[i].creds;
	}

	double cg = cgpa/(double)total_credits;
	cgpa = round(cg*100);
	yyout = fopen("output.txt","w");
	fprintf(yyout,"@%d@%d@%d@%d#", num_records,comments,s[stud_found].num_courses,cgpa);
	
	
	fclose(yyout);

}

int yywrap(){return(1);}