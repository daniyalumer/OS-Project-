
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
 int cont=1;


char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	394080e7          	jalr	916(ra) # 3a4 <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	368080e7          	jalr	872(ra) # 3a4 <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	346080e7          	jalr	838(ra) # 3a4 <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	fba98993          	addi	s3,s3,-70 # 1020 <buf.0>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	4a0080e7          	jalr	1184(ra) # 516 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	324080e7          	jalr	804(ra) # 3a4 <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	316080e7          	jalr	790(ra) # 3a4 <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	326080e7          	jalr	806(ra) # 3ce <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:
void
ls(char *path,int flag)
{
  b4:	d8010113          	addi	sp,sp,-640
  b8:	26113c23          	sd	ra,632(sp)
  bc:	26813823          	sd	s0,624(sp)
  c0:	26913423          	sd	s1,616(sp)
  c4:	27213023          	sd	s2,608(sp)
  c8:	25313c23          	sd	s3,600(sp)
  cc:	25413823          	sd	s4,592(sp)
  d0:	25513423          	sd	s5,584(sp)
  d4:	25613023          	sd	s6,576(sp)
  d8:	23713c23          	sd	s7,568(sp)
  dc:	23813823          	sd	s8,560(sp)
  e0:	0500                	addi	s0,sp,640
  e2:	892a                	mv	s2,a0
  e4:	89ae                	mv	s3,a1
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  if((fd = open(path, 0)) < 0){
  e6:	4581                	li	a1,0
  e8:	00000097          	auipc	ra,0x0
  ec:	520080e7          	jalr	1312(ra) # 608 <open>
  f0:	08054763          	bltz	a0,17e <ls+0xca>
  f4:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  f6:	d8840593          	addi	a1,s0,-632
  fa:	00000097          	auipc	ra,0x0
  fe:	526080e7          	jalr	1318(ra) # 620 <fstat>
 102:	08054963          	bltz	a0,194 <ls+0xe0>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
 106:	d9041783          	lh	a5,-624(s0)
 10a:	0007869b          	sext.w	a3,a5
 10e:	4705                	li	a4,1
 110:	0ae68263          	beq	a3,a4,1b4 <ls+0x100>
 114:	37f9                	addiw	a5,a5,-2
 116:	17c2                	slli	a5,a5,0x30
 118:	93c1                	srli	a5,a5,0x30
 11a:	02f76663          	bltu	a4,a5,146 <ls+0x92>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 11e:	854a                	mv	a0,s2
 120:	00000097          	auipc	ra,0x0
 124:	ee0080e7          	jalr	-288(ra) # 0 <fmtname>
 128:	85aa                	mv	a1,a0
 12a:	d9843703          	ld	a4,-616(s0)
 12e:	d8c42683          	lw	a3,-628(s0)
 132:	d9041603          	lh	a2,-624(s0)
 136:	00001517          	auipc	a0,0x1
 13a:	9fa50513          	addi	a0,a0,-1542 # b30 <malloc+0x11e>
 13e:	00001097          	auipc	ra,0x1
 142:	81c080e7          	jalr	-2020(ra) # 95a <printf>
        }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 146:	8526                	mv	a0,s1
 148:	00000097          	auipc	ra,0x0
 14c:	4a8080e7          	jalr	1192(ra) # 5f0 <close>
}
 150:	27813083          	ld	ra,632(sp)
 154:	27013403          	ld	s0,624(sp)
 158:	26813483          	ld	s1,616(sp)
 15c:	26013903          	ld	s2,608(sp)
 160:	25813983          	ld	s3,600(sp)
 164:	25013a03          	ld	s4,592(sp)
 168:	24813a83          	ld	s5,584(sp)
 16c:	24013b03          	ld	s6,576(sp)
 170:	23813b83          	ld	s7,568(sp)
 174:	23013c03          	ld	s8,560(sp)
 178:	28010113          	addi	sp,sp,640
 17c:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 17e:	864a                	mv	a2,s2
 180:	00001597          	auipc	a1,0x1
 184:	98058593          	addi	a1,a1,-1664 # b00 <malloc+0xee>
 188:	4509                	li	a0,2
 18a:	00000097          	auipc	ra,0x0
 18e:	7a2080e7          	jalr	1954(ra) # 92c <fprintf>
    return;
 192:	bf7d                	j	150 <ls+0x9c>
    fprintf(2, "ls: cannot stat %s\n", path);
 194:	864a                	mv	a2,s2
 196:	00001597          	auipc	a1,0x1
 19a:	98258593          	addi	a1,a1,-1662 # b18 <malloc+0x106>
 19e:	4509                	li	a0,2
 1a0:	00000097          	auipc	ra,0x0
 1a4:	78c080e7          	jalr	1932(ra) # 92c <fprintf>
    close(fd);
 1a8:	8526                	mv	a0,s1
 1aa:	00000097          	auipc	ra,0x0
 1ae:	446080e7          	jalr	1094(ra) # 5f0 <close>
    return;
 1b2:	bf79                	j	150 <ls+0x9c>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 1b4:	854a                	mv	a0,s2
 1b6:	00000097          	auipc	ra,0x0
 1ba:	1ee080e7          	jalr	494(ra) # 3a4 <strlen>
 1be:	2541                	addiw	a0,a0,16
 1c0:	20000793          	li	a5,512
 1c4:	00a7fb63          	bgeu	a5,a0,1da <ls+0x126>
      printf("ls: path too long\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	97850513          	addi	a0,a0,-1672 # b40 <malloc+0x12e>
 1d0:	00000097          	auipc	ra,0x0
 1d4:	78a080e7          	jalr	1930(ra) # 95a <printf>
      break;
 1d8:	b7bd                	j	146 <ls+0x92>
    strcpy(buf, path);
 1da:	85ca                	mv	a1,s2
 1dc:	db040513          	addi	a0,s0,-592
 1e0:	00000097          	auipc	ra,0x0
 1e4:	17c080e7          	jalr	380(ra) # 35c <strcpy>
    p = buf+strlen(buf);
 1e8:	db040513          	addi	a0,s0,-592
 1ec:	00000097          	auipc	ra,0x0
 1f0:	1b8080e7          	jalr	440(ra) # 3a4 <strlen>
 1f4:	1502                	slli	a0,a0,0x20
 1f6:	9101                	srli	a0,a0,0x20
 1f8:	db040793          	addi	a5,s0,-592
 1fc:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 200:	00190a93          	addi	s5,s2,1
 204:	02f00793          	li	a5,47
 208:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 20c:	00001b17          	auipc	s6,0x1
 210:	954b0b13          	addi	s6,s6,-1708 # b60 <malloc+0x14e>
        printf("%d\t",cont);
 214:	00001a17          	auipc	s4,0x1
 218:	deca0a13          	addi	s4,s4,-532 # 1000 <cont>
 21c:	00001b97          	auipc	s7,0x1
 220:	93cb8b93          	addi	s7,s7,-1732 # b58 <malloc+0x146>
        printf("ls: cannot stat %s\n", buf);
 224:	00001c17          	auipc	s8,0x1
 228:	8f4c0c13          	addi	s8,s8,-1804 # b18 <malloc+0x106>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 22c:	a81d                	j	262 <ls+0x1ae>
        printf("ls: cannot stat %s\n", buf);
 22e:	db040593          	addi	a1,s0,-592
 232:	8562                	mv	a0,s8
 234:	00000097          	auipc	ra,0x0
 238:	726080e7          	jalr	1830(ra) # 95a <printf>
        continue;
 23c:	a01d                	j	262 <ls+0x1ae>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 23e:	db040513          	addi	a0,s0,-592
 242:	00000097          	auipc	ra,0x0
 246:	dbe080e7          	jalr	-578(ra) # 0 <fmtname>
 24a:	85aa                	mv	a1,a0
 24c:	d9843703          	ld	a4,-616(s0)
 250:	d8c42683          	lw	a3,-628(s0)
 254:	d9041603          	lh	a2,-624(s0)
 258:	855a                	mv	a0,s6
 25a:	00000097          	auipc	ra,0x0
 25e:	700080e7          	jalr	1792(ra) # 95a <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 262:	4641                	li	a2,16
 264:	da040593          	addi	a1,s0,-608
 268:	8526                	mv	a0,s1
 26a:	00000097          	auipc	ra,0x0
 26e:	376080e7          	jalr	886(ra) # 5e0 <read>
 272:	47c1                	li	a5,16
 274:	ecf519e3          	bne	a0,a5,146 <ls+0x92>
      if(de.inum == 0)
 278:	da045783          	lhu	a5,-608(s0)
 27c:	d3fd                	beqz	a5,262 <ls+0x1ae>
      memmove(p, de.name, DIRSIZ);
 27e:	4639                	li	a2,14
 280:	da240593          	addi	a1,s0,-606
 284:	8556                	mv	a0,s5
 286:	00000097          	auipc	ra,0x0
 28a:	290080e7          	jalr	656(ra) # 516 <memmove>
      p[DIRSIZ] = 0;
 28e:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 292:	d8840593          	addi	a1,s0,-632
 296:	db040513          	addi	a0,s0,-592
 29a:	00000097          	auipc	ra,0x0
 29e:	1ee080e7          	jalr	494(ra) # 488 <stat>
 2a2:	f80546e3          	bltz	a0,22e <ls+0x17a>
      if(flag>=1){
 2a6:	f9305ce3          	blez	s3,23e <ls+0x18a>
        printf("%d\t",cont);
 2aa:	000a2583          	lw	a1,0(s4)
 2ae:	855e                	mv	a0,s7
 2b0:	00000097          	auipc	ra,0x0
 2b4:	6aa080e7          	jalr	1706(ra) # 95a <printf>
        cont+=1;
 2b8:	000a2783          	lw	a5,0(s4)
 2bc:	2785                	addiw	a5,a5,1
 2be:	00fa2023          	sw	a5,0(s4)
 2c2:	bfb5                	j	23e <ls+0x18a>

00000000000002c4 <main>:

int
main(int argc, char *argv[])
{
 2c4:	7179                	addi	sp,sp,-48
 2c6:	f406                	sd	ra,40(sp)
 2c8:	f022                	sd	s0,32(sp)
 2ca:	ec26                	sd	s1,24(sp)
 2cc:	e84a                	sd	s2,16(sp)
 2ce:	e44e                	sd	s3,8(sp)
 2d0:	1800                	addi	s0,sp,48
 2d2:	89aa                	mv	s3,a0
 2d4:	892e                	mv	s2,a1
  int flag=0;
  int i;

  if(strcmp(argv[1],"-n")==0)
 2d6:	00001597          	auipc	a1,0x1
 2da:	89a58593          	addi	a1,a1,-1894 # b70 <malloc+0x15e>
 2de:	00893503          	ld	a0,8(s2)
 2e2:	00000097          	auipc	ra,0x0
 2e6:	096080e7          	jalr	150(ra) # 378 <strcmp>
 2ea:	00153493          	seqz	s1,a0
  {
    flag+=1;
  }
  if(argc < 2+flag){
 2ee:	2485                	addiw	s1,s1,1
 2f0:	0334da63          	bge	s1,s3,324 <main+0x60>
    ls(".",flag);
    exit(0);
  }
  for(i=flag+1; i<argc; i++)
 2f4:	00349793          	slli	a5,s1,0x3
 2f8:	993e                	add	s2,s2,a5
    ls(argv[i],i);
 2fa:	85a6                	mv	a1,s1
 2fc:	00093503          	ld	a0,0(s2)
 300:	00000097          	auipc	ra,0x0
 304:	db4080e7          	jalr	-588(ra) # b4 <ls>
  for(i=flag+1; i<argc; i++)
 308:	2485                	addiw	s1,s1,1
 30a:	0921                	addi	s2,s2,8
 30c:	fe9997e3          	bne	s3,s1,2fa <main+0x36>
  cont=1;
 310:	4785                	li	a5,1
 312:	00001717          	auipc	a4,0x1
 316:	cef72723          	sw	a5,-786(a4) # 1000 <cont>
  exit(0);
 31a:	4501                	li	a0,0
 31c:	00000097          	auipc	ra,0x0
 320:	2ac080e7          	jalr	684(ra) # 5c8 <exit>
 324:	00153593          	seqz	a1,a0
    ls(".",flag);
 328:	00001517          	auipc	a0,0x1
 32c:	85050513          	addi	a0,a0,-1968 # b78 <malloc+0x166>
 330:	00000097          	auipc	ra,0x0
 334:	d84080e7          	jalr	-636(ra) # b4 <ls>
    exit(0);
 338:	4501                	li	a0,0
 33a:	00000097          	auipc	ra,0x0
 33e:	28e080e7          	jalr	654(ra) # 5c8 <exit>

0000000000000342 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 342:	1141                	addi	sp,sp,-16
 344:	e406                	sd	ra,8(sp)
 346:	e022                	sd	s0,0(sp)
 348:	0800                	addi	s0,sp,16
  extern int main();
  main();
 34a:	00000097          	auipc	ra,0x0
 34e:	f7a080e7          	jalr	-134(ra) # 2c4 <main>
  exit(0);
 352:	4501                	li	a0,0
 354:	00000097          	auipc	ra,0x0
 358:	274080e7          	jalr	628(ra) # 5c8 <exit>

000000000000035c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 35c:	1141                	addi	sp,sp,-16
 35e:	e422                	sd	s0,8(sp)
 360:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 362:	87aa                	mv	a5,a0
 364:	0585                	addi	a1,a1,1
 366:	0785                	addi	a5,a5,1
 368:	fff5c703          	lbu	a4,-1(a1)
 36c:	fee78fa3          	sb	a4,-1(a5)
 370:	fb75                	bnez	a4,364 <strcpy+0x8>
    ;
  return os;
}
 372:	6422                	ld	s0,8(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret

0000000000000378 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 378:	1141                	addi	sp,sp,-16
 37a:	e422                	sd	s0,8(sp)
 37c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 37e:	00054783          	lbu	a5,0(a0)
 382:	cb91                	beqz	a5,396 <strcmp+0x1e>
 384:	0005c703          	lbu	a4,0(a1)
 388:	00f71763          	bne	a4,a5,396 <strcmp+0x1e>
    p++, q++;
 38c:	0505                	addi	a0,a0,1
 38e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 390:	00054783          	lbu	a5,0(a0)
 394:	fbe5                	bnez	a5,384 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 396:	0005c503          	lbu	a0,0(a1)
}
 39a:	40a7853b          	subw	a0,a5,a0
 39e:	6422                	ld	s0,8(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret

00000000000003a4 <strlen>:

uint
strlen(const char *s)
{
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e422                	sd	s0,8(sp)
 3a8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3aa:	00054783          	lbu	a5,0(a0)
 3ae:	cf91                	beqz	a5,3ca <strlen+0x26>
 3b0:	0505                	addi	a0,a0,1
 3b2:	87aa                	mv	a5,a0
 3b4:	4685                	li	a3,1
 3b6:	9e89                	subw	a3,a3,a0
 3b8:	00f6853b          	addw	a0,a3,a5
 3bc:	0785                	addi	a5,a5,1
 3be:	fff7c703          	lbu	a4,-1(a5)
 3c2:	fb7d                	bnez	a4,3b8 <strlen+0x14>
    ;
  return n;
}
 3c4:	6422                	ld	s0,8(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret
  for(n = 0; s[n]; n++)
 3ca:	4501                	li	a0,0
 3cc:	bfe5                	j	3c4 <strlen+0x20>

00000000000003ce <memset>:

void*
memset(void *dst, int c, uint n)
{
 3ce:	1141                	addi	sp,sp,-16
 3d0:	e422                	sd	s0,8(sp)
 3d2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3d4:	ca19                	beqz	a2,3ea <memset+0x1c>
 3d6:	87aa                	mv	a5,a0
 3d8:	1602                	slli	a2,a2,0x20
 3da:	9201                	srli	a2,a2,0x20
 3dc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3e0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3e4:	0785                	addi	a5,a5,1
 3e6:	fee79de3          	bne	a5,a4,3e0 <memset+0x12>
  }
  return dst;
}
 3ea:	6422                	ld	s0,8(sp)
 3ec:	0141                	addi	sp,sp,16
 3ee:	8082                	ret

00000000000003f0 <strchr>:

char*
strchr(const char *s, char c)
{
 3f0:	1141                	addi	sp,sp,-16
 3f2:	e422                	sd	s0,8(sp)
 3f4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3f6:	00054783          	lbu	a5,0(a0)
 3fa:	cb99                	beqz	a5,410 <strchr+0x20>
    if(*s == c)
 3fc:	00f58763          	beq	a1,a5,40a <strchr+0x1a>
  for(; *s; s++)
 400:	0505                	addi	a0,a0,1
 402:	00054783          	lbu	a5,0(a0)
 406:	fbfd                	bnez	a5,3fc <strchr+0xc>
      return (char*)s;
  return 0;
 408:	4501                	li	a0,0
}
 40a:	6422                	ld	s0,8(sp)
 40c:	0141                	addi	sp,sp,16
 40e:	8082                	ret
  return 0;
 410:	4501                	li	a0,0
 412:	bfe5                	j	40a <strchr+0x1a>

0000000000000414 <gets>:

char*
gets(char *buf, int max)
{
 414:	711d                	addi	sp,sp,-96
 416:	ec86                	sd	ra,88(sp)
 418:	e8a2                	sd	s0,80(sp)
 41a:	e4a6                	sd	s1,72(sp)
 41c:	e0ca                	sd	s2,64(sp)
 41e:	fc4e                	sd	s3,56(sp)
 420:	f852                	sd	s4,48(sp)
 422:	f456                	sd	s5,40(sp)
 424:	f05a                	sd	s6,32(sp)
 426:	ec5e                	sd	s7,24(sp)
 428:	1080                	addi	s0,sp,96
 42a:	8baa                	mv	s7,a0
 42c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 42e:	892a                	mv	s2,a0
 430:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 432:	4aa9                	li	s5,10
 434:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 436:	89a6                	mv	s3,s1
 438:	2485                	addiw	s1,s1,1
 43a:	0344d863          	bge	s1,s4,46a <gets+0x56>
    cc = read(0, &c, 1);
 43e:	4605                	li	a2,1
 440:	faf40593          	addi	a1,s0,-81
 444:	4501                	li	a0,0
 446:	00000097          	auipc	ra,0x0
 44a:	19a080e7          	jalr	410(ra) # 5e0 <read>
    if(cc < 1)
 44e:	00a05e63          	blez	a0,46a <gets+0x56>
    buf[i++] = c;
 452:	faf44783          	lbu	a5,-81(s0)
 456:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 45a:	01578763          	beq	a5,s5,468 <gets+0x54>
 45e:	0905                	addi	s2,s2,1
 460:	fd679be3          	bne	a5,s6,436 <gets+0x22>
  for(i=0; i+1 < max; ){
 464:	89a6                	mv	s3,s1
 466:	a011                	j	46a <gets+0x56>
 468:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 46a:	99de                	add	s3,s3,s7
 46c:	00098023          	sb	zero,0(s3)
  return buf;
}
 470:	855e                	mv	a0,s7
 472:	60e6                	ld	ra,88(sp)
 474:	6446                	ld	s0,80(sp)
 476:	64a6                	ld	s1,72(sp)
 478:	6906                	ld	s2,64(sp)
 47a:	79e2                	ld	s3,56(sp)
 47c:	7a42                	ld	s4,48(sp)
 47e:	7aa2                	ld	s5,40(sp)
 480:	7b02                	ld	s6,32(sp)
 482:	6be2                	ld	s7,24(sp)
 484:	6125                	addi	sp,sp,96
 486:	8082                	ret

0000000000000488 <stat>:

int
stat(const char *n, struct stat *st)
{
 488:	1101                	addi	sp,sp,-32
 48a:	ec06                	sd	ra,24(sp)
 48c:	e822                	sd	s0,16(sp)
 48e:	e426                	sd	s1,8(sp)
 490:	e04a                	sd	s2,0(sp)
 492:	1000                	addi	s0,sp,32
 494:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 496:	4581                	li	a1,0
 498:	00000097          	auipc	ra,0x0
 49c:	170080e7          	jalr	368(ra) # 608 <open>
  if(fd < 0)
 4a0:	02054563          	bltz	a0,4ca <stat+0x42>
 4a4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4a6:	85ca                	mv	a1,s2
 4a8:	00000097          	auipc	ra,0x0
 4ac:	178080e7          	jalr	376(ra) # 620 <fstat>
 4b0:	892a                	mv	s2,a0
  close(fd);
 4b2:	8526                	mv	a0,s1
 4b4:	00000097          	auipc	ra,0x0
 4b8:	13c080e7          	jalr	316(ra) # 5f0 <close>
  return r;
}
 4bc:	854a                	mv	a0,s2
 4be:	60e2                	ld	ra,24(sp)
 4c0:	6442                	ld	s0,16(sp)
 4c2:	64a2                	ld	s1,8(sp)
 4c4:	6902                	ld	s2,0(sp)
 4c6:	6105                	addi	sp,sp,32
 4c8:	8082                	ret
    return -1;
 4ca:	597d                	li	s2,-1
 4cc:	bfc5                	j	4bc <stat+0x34>

00000000000004ce <atoi>:

int
atoi(const char *s)
{
 4ce:	1141                	addi	sp,sp,-16
 4d0:	e422                	sd	s0,8(sp)
 4d2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4d4:	00054683          	lbu	a3,0(a0)
 4d8:	fd06879b          	addiw	a5,a3,-48
 4dc:	0ff7f793          	zext.b	a5,a5
 4e0:	4625                	li	a2,9
 4e2:	02f66863          	bltu	a2,a5,512 <atoi+0x44>
 4e6:	872a                	mv	a4,a0
  n = 0;
 4e8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 4ea:	0705                	addi	a4,a4,1
 4ec:	0025179b          	slliw	a5,a0,0x2
 4f0:	9fa9                	addw	a5,a5,a0
 4f2:	0017979b          	slliw	a5,a5,0x1
 4f6:	9fb5                	addw	a5,a5,a3
 4f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4fc:	00074683          	lbu	a3,0(a4)
 500:	fd06879b          	addiw	a5,a3,-48
 504:	0ff7f793          	zext.b	a5,a5
 508:	fef671e3          	bgeu	a2,a5,4ea <atoi+0x1c>
  return n;
}
 50c:	6422                	ld	s0,8(sp)
 50e:	0141                	addi	sp,sp,16
 510:	8082                	ret
  n = 0;
 512:	4501                	li	a0,0
 514:	bfe5                	j	50c <atoi+0x3e>

0000000000000516 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 516:	1141                	addi	sp,sp,-16
 518:	e422                	sd	s0,8(sp)
 51a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 51c:	02b57463          	bgeu	a0,a1,544 <memmove+0x2e>
    while(n-- > 0)
 520:	00c05f63          	blez	a2,53e <memmove+0x28>
 524:	1602                	slli	a2,a2,0x20
 526:	9201                	srli	a2,a2,0x20
 528:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 52c:	872a                	mv	a4,a0
      *dst++ = *src++;
 52e:	0585                	addi	a1,a1,1
 530:	0705                	addi	a4,a4,1
 532:	fff5c683          	lbu	a3,-1(a1)
 536:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 53a:	fee79ae3          	bne	a5,a4,52e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 53e:	6422                	ld	s0,8(sp)
 540:	0141                	addi	sp,sp,16
 542:	8082                	ret
    dst += n;
 544:	00c50733          	add	a4,a0,a2
    src += n;
 548:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 54a:	fec05ae3          	blez	a2,53e <memmove+0x28>
 54e:	fff6079b          	addiw	a5,a2,-1
 552:	1782                	slli	a5,a5,0x20
 554:	9381                	srli	a5,a5,0x20
 556:	fff7c793          	not	a5,a5
 55a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 55c:	15fd                	addi	a1,a1,-1
 55e:	177d                	addi	a4,a4,-1
 560:	0005c683          	lbu	a3,0(a1)
 564:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 568:	fee79ae3          	bne	a5,a4,55c <memmove+0x46>
 56c:	bfc9                	j	53e <memmove+0x28>

000000000000056e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 56e:	1141                	addi	sp,sp,-16
 570:	e422                	sd	s0,8(sp)
 572:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 574:	ca05                	beqz	a2,5a4 <memcmp+0x36>
 576:	fff6069b          	addiw	a3,a2,-1
 57a:	1682                	slli	a3,a3,0x20
 57c:	9281                	srli	a3,a3,0x20
 57e:	0685                	addi	a3,a3,1
 580:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 582:	00054783          	lbu	a5,0(a0)
 586:	0005c703          	lbu	a4,0(a1)
 58a:	00e79863          	bne	a5,a4,59a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 58e:	0505                	addi	a0,a0,1
    p2++;
 590:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 592:	fed518e3          	bne	a0,a3,582 <memcmp+0x14>
  }
  return 0;
 596:	4501                	li	a0,0
 598:	a019                	j	59e <memcmp+0x30>
      return *p1 - *p2;
 59a:	40e7853b          	subw	a0,a5,a4
}
 59e:	6422                	ld	s0,8(sp)
 5a0:	0141                	addi	sp,sp,16
 5a2:	8082                	ret
  return 0;
 5a4:	4501                	li	a0,0
 5a6:	bfe5                	j	59e <memcmp+0x30>

00000000000005a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5a8:	1141                	addi	sp,sp,-16
 5aa:	e406                	sd	ra,8(sp)
 5ac:	e022                	sd	s0,0(sp)
 5ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5b0:	00000097          	auipc	ra,0x0
 5b4:	f66080e7          	jalr	-154(ra) # 516 <memmove>
}
 5b8:	60a2                	ld	ra,8(sp)
 5ba:	6402                	ld	s0,0(sp)
 5bc:	0141                	addi	sp,sp,16
 5be:	8082                	ret

00000000000005c0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5c0:	4885                	li	a7,1
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5c8:	4889                	li	a7,2
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5d0:	488d                	li	a7,3
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5d8:	4891                	li	a7,4
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <read>:
.global read
read:
 li a7, SYS_read
 5e0:	4895                	li	a7,5
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <write>:
.global write
write:
 li a7, SYS_write
 5e8:	48c1                	li	a7,16
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <close>:
.global close
close:
 li a7, SYS_close
 5f0:	48d5                	li	a7,21
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5f8:	4899                	li	a7,6
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <exec>:
.global exec
exec:
 li a7, SYS_exec
 600:	489d                	li	a7,7
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <open>:
.global open
open:
 li a7, SYS_open
 608:	48bd                	li	a7,15
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 610:	48c5                	li	a7,17
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 618:	48c9                	li	a7,18
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 620:	48a1                	li	a7,8
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <link>:
.global link
link:
 li a7, SYS_link
 628:	48cd                	li	a7,19
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 630:	48d1                	li	a7,20
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 638:	48a5                	li	a7,9
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <dup>:
.global dup
dup:
 li a7, SYS_dup
 640:	48a9                	li	a7,10
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 648:	48ad                	li	a7,11
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 650:	48b1                	li	a7,12
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 658:	48b5                	li	a7,13
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 660:	48b9                	li	a7,14
 ecall
 662:	00000073          	ecall
 ret
 666:	8082                	ret

0000000000000668 <upttime>:
.global upttime
upttime:
 li a7, SYS_upttime
 668:	48d9                	li	a7,22
 ecall
 66a:	00000073          	ecall
 ret
 66e:	8082                	ret

0000000000000670 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 670:	48dd                	li	a7,23
 ecall
 672:	00000073          	ecall
 ret
 676:	8082                	ret

0000000000000678 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 678:	48e1                	li	a7,24
 ecall
 67a:	00000073          	ecall
 ret
 67e:	8082                	ret

0000000000000680 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 680:	1101                	addi	sp,sp,-32
 682:	ec06                	sd	ra,24(sp)
 684:	e822                	sd	s0,16(sp)
 686:	1000                	addi	s0,sp,32
 688:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 68c:	4605                	li	a2,1
 68e:	fef40593          	addi	a1,s0,-17
 692:	00000097          	auipc	ra,0x0
 696:	f56080e7          	jalr	-170(ra) # 5e8 <write>
}
 69a:	60e2                	ld	ra,24(sp)
 69c:	6442                	ld	s0,16(sp)
 69e:	6105                	addi	sp,sp,32
 6a0:	8082                	ret

00000000000006a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6a2:	7139                	addi	sp,sp,-64
 6a4:	fc06                	sd	ra,56(sp)
 6a6:	f822                	sd	s0,48(sp)
 6a8:	f426                	sd	s1,40(sp)
 6aa:	f04a                	sd	s2,32(sp)
 6ac:	ec4e                	sd	s3,24(sp)
 6ae:	0080                	addi	s0,sp,64
 6b0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6b2:	c299                	beqz	a3,6b8 <printint+0x16>
 6b4:	0805c963          	bltz	a1,746 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6b8:	2581                	sext.w	a1,a1
  neg = 0;
 6ba:	4881                	li	a7,0
 6bc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6c0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6c2:	2601                	sext.w	a2,a2
 6c4:	00000517          	auipc	a0,0x0
 6c8:	51c50513          	addi	a0,a0,1308 # be0 <digits>
 6cc:	883a                	mv	a6,a4
 6ce:	2705                	addiw	a4,a4,1
 6d0:	02c5f7bb          	remuw	a5,a1,a2
 6d4:	1782                	slli	a5,a5,0x20
 6d6:	9381                	srli	a5,a5,0x20
 6d8:	97aa                	add	a5,a5,a0
 6da:	0007c783          	lbu	a5,0(a5)
 6de:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6e2:	0005879b          	sext.w	a5,a1
 6e6:	02c5d5bb          	divuw	a1,a1,a2
 6ea:	0685                	addi	a3,a3,1
 6ec:	fec7f0e3          	bgeu	a5,a2,6cc <printint+0x2a>
  if(neg)
 6f0:	00088c63          	beqz	a7,708 <printint+0x66>
    buf[i++] = '-';
 6f4:	fd070793          	addi	a5,a4,-48
 6f8:	00878733          	add	a4,a5,s0
 6fc:	02d00793          	li	a5,45
 700:	fef70823          	sb	a5,-16(a4)
 704:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 708:	02e05863          	blez	a4,738 <printint+0x96>
 70c:	fc040793          	addi	a5,s0,-64
 710:	00e78933          	add	s2,a5,a4
 714:	fff78993          	addi	s3,a5,-1
 718:	99ba                	add	s3,s3,a4
 71a:	377d                	addiw	a4,a4,-1
 71c:	1702                	slli	a4,a4,0x20
 71e:	9301                	srli	a4,a4,0x20
 720:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 724:	fff94583          	lbu	a1,-1(s2)
 728:	8526                	mv	a0,s1
 72a:	00000097          	auipc	ra,0x0
 72e:	f56080e7          	jalr	-170(ra) # 680 <putc>
  while(--i >= 0)
 732:	197d                	addi	s2,s2,-1
 734:	ff3918e3          	bne	s2,s3,724 <printint+0x82>
}
 738:	70e2                	ld	ra,56(sp)
 73a:	7442                	ld	s0,48(sp)
 73c:	74a2                	ld	s1,40(sp)
 73e:	7902                	ld	s2,32(sp)
 740:	69e2                	ld	s3,24(sp)
 742:	6121                	addi	sp,sp,64
 744:	8082                	ret
    x = -xx;
 746:	40b005bb          	negw	a1,a1
    neg = 1;
 74a:	4885                	li	a7,1
    x = -xx;
 74c:	bf85                	j	6bc <printint+0x1a>

000000000000074e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 74e:	7119                	addi	sp,sp,-128
 750:	fc86                	sd	ra,120(sp)
 752:	f8a2                	sd	s0,112(sp)
 754:	f4a6                	sd	s1,104(sp)
 756:	f0ca                	sd	s2,96(sp)
 758:	ecce                	sd	s3,88(sp)
 75a:	e8d2                	sd	s4,80(sp)
 75c:	e4d6                	sd	s5,72(sp)
 75e:	e0da                	sd	s6,64(sp)
 760:	fc5e                	sd	s7,56(sp)
 762:	f862                	sd	s8,48(sp)
 764:	f466                	sd	s9,40(sp)
 766:	f06a                	sd	s10,32(sp)
 768:	ec6e                	sd	s11,24(sp)
 76a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 76c:	0005c903          	lbu	s2,0(a1)
 770:	18090f63          	beqz	s2,90e <vprintf+0x1c0>
 774:	8aaa                	mv	s5,a0
 776:	8b32                	mv	s6,a2
 778:	00158493          	addi	s1,a1,1
  state = 0;
 77c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 77e:	02500a13          	li	s4,37
 782:	4c55                	li	s8,21
 784:	00000c97          	auipc	s9,0x0
 788:	404c8c93          	addi	s9,s9,1028 # b88 <malloc+0x176>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 78c:	02800d93          	li	s11,40
  putc(fd, 'x');
 790:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 792:	00000b97          	auipc	s7,0x0
 796:	44eb8b93          	addi	s7,s7,1102 # be0 <digits>
 79a:	a839                	j	7b8 <vprintf+0x6a>
        putc(fd, c);
 79c:	85ca                	mv	a1,s2
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	ee0080e7          	jalr	-288(ra) # 680 <putc>
 7a8:	a019                	j	7ae <vprintf+0x60>
    } else if(state == '%'){
 7aa:	01498d63          	beq	s3,s4,7c4 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 7ae:	0485                	addi	s1,s1,1
 7b0:	fff4c903          	lbu	s2,-1(s1)
 7b4:	14090d63          	beqz	s2,90e <vprintf+0x1c0>
    if(state == 0){
 7b8:	fe0999e3          	bnez	s3,7aa <vprintf+0x5c>
      if(c == '%'){
 7bc:	ff4910e3          	bne	s2,s4,79c <vprintf+0x4e>
        state = '%';
 7c0:	89d2                	mv	s3,s4
 7c2:	b7f5                	j	7ae <vprintf+0x60>
      if(c == 'd'){
 7c4:	11490c63          	beq	s2,s4,8dc <vprintf+0x18e>
 7c8:	f9d9079b          	addiw	a5,s2,-99
 7cc:	0ff7f793          	zext.b	a5,a5
 7d0:	10fc6e63          	bltu	s8,a5,8ec <vprintf+0x19e>
 7d4:	f9d9079b          	addiw	a5,s2,-99
 7d8:	0ff7f713          	zext.b	a4,a5
 7dc:	10ec6863          	bltu	s8,a4,8ec <vprintf+0x19e>
 7e0:	00271793          	slli	a5,a4,0x2
 7e4:	97e6                	add	a5,a5,s9
 7e6:	439c                	lw	a5,0(a5)
 7e8:	97e6                	add	a5,a5,s9
 7ea:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 7ec:	008b0913          	addi	s2,s6,8
 7f0:	4685                	li	a3,1
 7f2:	4629                	li	a2,10
 7f4:	000b2583          	lw	a1,0(s6)
 7f8:	8556                	mv	a0,s5
 7fa:	00000097          	auipc	ra,0x0
 7fe:	ea8080e7          	jalr	-344(ra) # 6a2 <printint>
 802:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 804:	4981                	li	s3,0
 806:	b765                	j	7ae <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 808:	008b0913          	addi	s2,s6,8
 80c:	4681                	li	a3,0
 80e:	4629                	li	a2,10
 810:	000b2583          	lw	a1,0(s6)
 814:	8556                	mv	a0,s5
 816:	00000097          	auipc	ra,0x0
 81a:	e8c080e7          	jalr	-372(ra) # 6a2 <printint>
 81e:	8b4a                	mv	s6,s2
      state = 0;
 820:	4981                	li	s3,0
 822:	b771                	j	7ae <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 824:	008b0913          	addi	s2,s6,8
 828:	4681                	li	a3,0
 82a:	866a                	mv	a2,s10
 82c:	000b2583          	lw	a1,0(s6)
 830:	8556                	mv	a0,s5
 832:	00000097          	auipc	ra,0x0
 836:	e70080e7          	jalr	-400(ra) # 6a2 <printint>
 83a:	8b4a                	mv	s6,s2
      state = 0;
 83c:	4981                	li	s3,0
 83e:	bf85                	j	7ae <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 840:	008b0793          	addi	a5,s6,8
 844:	f8f43423          	sd	a5,-120(s0)
 848:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 84c:	03000593          	li	a1,48
 850:	8556                	mv	a0,s5
 852:	00000097          	auipc	ra,0x0
 856:	e2e080e7          	jalr	-466(ra) # 680 <putc>
  putc(fd, 'x');
 85a:	07800593          	li	a1,120
 85e:	8556                	mv	a0,s5
 860:	00000097          	auipc	ra,0x0
 864:	e20080e7          	jalr	-480(ra) # 680 <putc>
 868:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 86a:	03c9d793          	srli	a5,s3,0x3c
 86e:	97de                	add	a5,a5,s7
 870:	0007c583          	lbu	a1,0(a5)
 874:	8556                	mv	a0,s5
 876:	00000097          	auipc	ra,0x0
 87a:	e0a080e7          	jalr	-502(ra) # 680 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 87e:	0992                	slli	s3,s3,0x4
 880:	397d                	addiw	s2,s2,-1
 882:	fe0914e3          	bnez	s2,86a <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 886:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 88a:	4981                	li	s3,0
 88c:	b70d                	j	7ae <vprintf+0x60>
        s = va_arg(ap, char*);
 88e:	008b0913          	addi	s2,s6,8
 892:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 896:	02098163          	beqz	s3,8b8 <vprintf+0x16a>
        while(*s != 0){
 89a:	0009c583          	lbu	a1,0(s3)
 89e:	c5ad                	beqz	a1,908 <vprintf+0x1ba>
          putc(fd, *s);
 8a0:	8556                	mv	a0,s5
 8a2:	00000097          	auipc	ra,0x0
 8a6:	dde080e7          	jalr	-546(ra) # 680 <putc>
          s++;
 8aa:	0985                	addi	s3,s3,1
        while(*s != 0){
 8ac:	0009c583          	lbu	a1,0(s3)
 8b0:	f9e5                	bnez	a1,8a0 <vprintf+0x152>
        s = va_arg(ap, char*);
 8b2:	8b4a                	mv	s6,s2
      state = 0;
 8b4:	4981                	li	s3,0
 8b6:	bde5                	j	7ae <vprintf+0x60>
          s = "(null)";
 8b8:	00000997          	auipc	s3,0x0
 8bc:	2c898993          	addi	s3,s3,712 # b80 <malloc+0x16e>
        while(*s != 0){
 8c0:	85ee                	mv	a1,s11
 8c2:	bff9                	j	8a0 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 8c4:	008b0913          	addi	s2,s6,8
 8c8:	000b4583          	lbu	a1,0(s6)
 8cc:	8556                	mv	a0,s5
 8ce:	00000097          	auipc	ra,0x0
 8d2:	db2080e7          	jalr	-590(ra) # 680 <putc>
 8d6:	8b4a                	mv	s6,s2
      state = 0;
 8d8:	4981                	li	s3,0
 8da:	bdd1                	j	7ae <vprintf+0x60>
        putc(fd, c);
 8dc:	85d2                	mv	a1,s4
 8de:	8556                	mv	a0,s5
 8e0:	00000097          	auipc	ra,0x0
 8e4:	da0080e7          	jalr	-608(ra) # 680 <putc>
      state = 0;
 8e8:	4981                	li	s3,0
 8ea:	b5d1                	j	7ae <vprintf+0x60>
        putc(fd, '%');
 8ec:	85d2                	mv	a1,s4
 8ee:	8556                	mv	a0,s5
 8f0:	00000097          	auipc	ra,0x0
 8f4:	d90080e7          	jalr	-624(ra) # 680 <putc>
        putc(fd, c);
 8f8:	85ca                	mv	a1,s2
 8fa:	8556                	mv	a0,s5
 8fc:	00000097          	auipc	ra,0x0
 900:	d84080e7          	jalr	-636(ra) # 680 <putc>
      state = 0;
 904:	4981                	li	s3,0
 906:	b565                	j	7ae <vprintf+0x60>
        s = va_arg(ap, char*);
 908:	8b4a                	mv	s6,s2
      state = 0;
 90a:	4981                	li	s3,0
 90c:	b54d                	j	7ae <vprintf+0x60>
    }
  }
}
 90e:	70e6                	ld	ra,120(sp)
 910:	7446                	ld	s0,112(sp)
 912:	74a6                	ld	s1,104(sp)
 914:	7906                	ld	s2,96(sp)
 916:	69e6                	ld	s3,88(sp)
 918:	6a46                	ld	s4,80(sp)
 91a:	6aa6                	ld	s5,72(sp)
 91c:	6b06                	ld	s6,64(sp)
 91e:	7be2                	ld	s7,56(sp)
 920:	7c42                	ld	s8,48(sp)
 922:	7ca2                	ld	s9,40(sp)
 924:	7d02                	ld	s10,32(sp)
 926:	6de2                	ld	s11,24(sp)
 928:	6109                	addi	sp,sp,128
 92a:	8082                	ret

000000000000092c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 92c:	715d                	addi	sp,sp,-80
 92e:	ec06                	sd	ra,24(sp)
 930:	e822                	sd	s0,16(sp)
 932:	1000                	addi	s0,sp,32
 934:	e010                	sd	a2,0(s0)
 936:	e414                	sd	a3,8(s0)
 938:	e818                	sd	a4,16(s0)
 93a:	ec1c                	sd	a5,24(s0)
 93c:	03043023          	sd	a6,32(s0)
 940:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 944:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 948:	8622                	mv	a2,s0
 94a:	00000097          	auipc	ra,0x0
 94e:	e04080e7          	jalr	-508(ra) # 74e <vprintf>
}
 952:	60e2                	ld	ra,24(sp)
 954:	6442                	ld	s0,16(sp)
 956:	6161                	addi	sp,sp,80
 958:	8082                	ret

000000000000095a <printf>:

void
printf(const char *fmt, ...)
{
 95a:	711d                	addi	sp,sp,-96
 95c:	ec06                	sd	ra,24(sp)
 95e:	e822                	sd	s0,16(sp)
 960:	1000                	addi	s0,sp,32
 962:	e40c                	sd	a1,8(s0)
 964:	e810                	sd	a2,16(s0)
 966:	ec14                	sd	a3,24(s0)
 968:	f018                	sd	a4,32(s0)
 96a:	f41c                	sd	a5,40(s0)
 96c:	03043823          	sd	a6,48(s0)
 970:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 974:	00840613          	addi	a2,s0,8
 978:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 97c:	85aa                	mv	a1,a0
 97e:	4505                	li	a0,1
 980:	00000097          	auipc	ra,0x0
 984:	dce080e7          	jalr	-562(ra) # 74e <vprintf>
}
 988:	60e2                	ld	ra,24(sp)
 98a:	6442                	ld	s0,16(sp)
 98c:	6125                	addi	sp,sp,96
 98e:	8082                	ret

0000000000000990 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 990:	1141                	addi	sp,sp,-16
 992:	e422                	sd	s0,8(sp)
 994:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 996:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99a:	00000797          	auipc	a5,0x0
 99e:	6767b783          	ld	a5,1654(a5) # 1010 <freep>
 9a2:	a02d                	j	9cc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9a4:	4618                	lw	a4,8(a2)
 9a6:	9f2d                	addw	a4,a4,a1
 9a8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9ac:	6398                	ld	a4,0(a5)
 9ae:	6310                	ld	a2,0(a4)
 9b0:	a83d                	j	9ee <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9b2:	ff852703          	lw	a4,-8(a0)
 9b6:	9f31                	addw	a4,a4,a2
 9b8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9ba:	ff053683          	ld	a3,-16(a0)
 9be:	a091                	j	a02 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c0:	6398                	ld	a4,0(a5)
 9c2:	00e7e463          	bltu	a5,a4,9ca <free+0x3a>
 9c6:	00e6ea63          	bltu	a3,a4,9da <free+0x4a>
{
 9ca:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9cc:	fed7fae3          	bgeu	a5,a3,9c0 <free+0x30>
 9d0:	6398                	ld	a4,0(a5)
 9d2:	00e6e463          	bltu	a3,a4,9da <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9d6:	fee7eae3          	bltu	a5,a4,9ca <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9da:	ff852583          	lw	a1,-8(a0)
 9de:	6390                	ld	a2,0(a5)
 9e0:	02059813          	slli	a6,a1,0x20
 9e4:	01c85713          	srli	a4,a6,0x1c
 9e8:	9736                	add	a4,a4,a3
 9ea:	fae60de3          	beq	a2,a4,9a4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9ee:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9f2:	4790                	lw	a2,8(a5)
 9f4:	02061593          	slli	a1,a2,0x20
 9f8:	01c5d713          	srli	a4,a1,0x1c
 9fc:	973e                	add	a4,a4,a5
 9fe:	fae68ae3          	beq	a3,a4,9b2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 a02:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a04:	00000717          	auipc	a4,0x0
 a08:	60f73623          	sd	a5,1548(a4) # 1010 <freep>
}
 a0c:	6422                	ld	s0,8(sp)
 a0e:	0141                	addi	sp,sp,16
 a10:	8082                	ret

0000000000000a12 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a12:	7139                	addi	sp,sp,-64
 a14:	fc06                	sd	ra,56(sp)
 a16:	f822                	sd	s0,48(sp)
 a18:	f426                	sd	s1,40(sp)
 a1a:	f04a                	sd	s2,32(sp)
 a1c:	ec4e                	sd	s3,24(sp)
 a1e:	e852                	sd	s4,16(sp)
 a20:	e456                	sd	s5,8(sp)
 a22:	e05a                	sd	s6,0(sp)
 a24:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a26:	02051493          	slli	s1,a0,0x20
 a2a:	9081                	srli	s1,s1,0x20
 a2c:	04bd                	addi	s1,s1,15
 a2e:	8091                	srli	s1,s1,0x4
 a30:	0014899b          	addiw	s3,s1,1
 a34:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a36:	00000517          	auipc	a0,0x0
 a3a:	5da53503          	ld	a0,1498(a0) # 1010 <freep>
 a3e:	c515                	beqz	a0,a6a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a40:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a42:	4798                	lw	a4,8(a5)
 a44:	02977f63          	bgeu	a4,s1,a82 <malloc+0x70>
 a48:	8a4e                	mv	s4,s3
 a4a:	0009871b          	sext.w	a4,s3
 a4e:	6685                	lui	a3,0x1
 a50:	00d77363          	bgeu	a4,a3,a56 <malloc+0x44>
 a54:	6a05                	lui	s4,0x1
 a56:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a5a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a5e:	00000917          	auipc	s2,0x0
 a62:	5b290913          	addi	s2,s2,1458 # 1010 <freep>
  if(p == (char*)-1)
 a66:	5afd                	li	s5,-1
 a68:	a895                	j	adc <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a6a:	00000797          	auipc	a5,0x0
 a6e:	5c678793          	addi	a5,a5,1478 # 1030 <base>
 a72:	00000717          	auipc	a4,0x0
 a76:	58f73f23          	sd	a5,1438(a4) # 1010 <freep>
 a7a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a7c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a80:	b7e1                	j	a48 <malloc+0x36>
      if(p->s.size == nunits)
 a82:	02e48c63          	beq	s1,a4,aba <malloc+0xa8>
        p->s.size -= nunits;
 a86:	4137073b          	subw	a4,a4,s3
 a8a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a8c:	02071693          	slli	a3,a4,0x20
 a90:	01c6d713          	srli	a4,a3,0x1c
 a94:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a96:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a9a:	00000717          	auipc	a4,0x0
 a9e:	56a73b23          	sd	a0,1398(a4) # 1010 <freep>
      return (void*)(p + 1);
 aa2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 aa6:	70e2                	ld	ra,56(sp)
 aa8:	7442                	ld	s0,48(sp)
 aaa:	74a2                	ld	s1,40(sp)
 aac:	7902                	ld	s2,32(sp)
 aae:	69e2                	ld	s3,24(sp)
 ab0:	6a42                	ld	s4,16(sp)
 ab2:	6aa2                	ld	s5,8(sp)
 ab4:	6b02                	ld	s6,0(sp)
 ab6:	6121                	addi	sp,sp,64
 ab8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 aba:	6398                	ld	a4,0(a5)
 abc:	e118                	sd	a4,0(a0)
 abe:	bff1                	j	a9a <malloc+0x88>
  hp->s.size = nu;
 ac0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ac4:	0541                	addi	a0,a0,16
 ac6:	00000097          	auipc	ra,0x0
 aca:	eca080e7          	jalr	-310(ra) # 990 <free>
  return freep;
 ace:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ad2:	d971                	beqz	a0,aa6 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ad6:	4798                	lw	a4,8(a5)
 ad8:	fa9775e3          	bgeu	a4,s1,a82 <malloc+0x70>
    if(p == freep)
 adc:	00093703          	ld	a4,0(s2)
 ae0:	853e                	mv	a0,a5
 ae2:	fef719e3          	bne	a4,a5,ad4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 ae6:	8552                	mv	a0,s4
 ae8:	00000097          	auipc	ra,0x0
 aec:	b68080e7          	jalr	-1176(ra) # 650 <sbrk>
  if(p == (char*)-1)
 af0:	fd5518e3          	bne	a0,s5,ac0 <malloc+0xae>
        return 0;
 af4:	4501                	li	a0,0
 af6:	bf45                	j	aa6 <malloc+0x94>
