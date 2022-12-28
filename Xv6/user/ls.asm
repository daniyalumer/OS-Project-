
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
  14:	39e080e7          	jalr	926(ra) # 3ae <strlen>
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
  40:	372080e7          	jalr	882(ra) # 3ae <strlen>
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
  62:	350080e7          	jalr	848(ra) # 3ae <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	fba98993          	addi	s3,s3,-70 # 1020 <buf.0>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	4aa080e7          	jalr	1194(ra) # 520 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	32e080e7          	jalr	814(ra) # 3ae <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	320080e7          	jalr	800(ra) # 3ae <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	330080e7          	jalr	816(ra) # 3d8 <memset>
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
  ec:	52a080e7          	jalr	1322(ra) # 612 <open>
  f0:	08054763          	bltz	a0,17e <ls+0xca>
  f4:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  f6:	d8840593          	addi	a1,s0,-632
  fa:	00000097          	auipc	ra,0x0
  fe:	530080e7          	jalr	1328(ra) # 62a <fstat>
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
 13a:	9fa50513          	addi	a0,a0,-1542 # b30 <malloc+0x124>
 13e:	00001097          	auipc	ra,0x1
 142:	816080e7          	jalr	-2026(ra) # 954 <printf>
        }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 146:	8526                	mv	a0,s1
 148:	00000097          	auipc	ra,0x0
 14c:	4b2080e7          	jalr	1202(ra) # 5fa <close>
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
 184:	98058593          	addi	a1,a1,-1664 # b00 <malloc+0xf4>
 188:	4509                	li	a0,2
 18a:	00000097          	auipc	ra,0x0
 18e:	79c080e7          	jalr	1948(ra) # 926 <fprintf>
    return;
 192:	bf7d                	j	150 <ls+0x9c>
    fprintf(2, "ls: cannot stat %s\n", path);
 194:	864a                	mv	a2,s2
 196:	00001597          	auipc	a1,0x1
 19a:	98258593          	addi	a1,a1,-1662 # b18 <malloc+0x10c>
 19e:	4509                	li	a0,2
 1a0:	00000097          	auipc	ra,0x0
 1a4:	786080e7          	jalr	1926(ra) # 926 <fprintf>
    close(fd);
 1a8:	8526                	mv	a0,s1
 1aa:	00000097          	auipc	ra,0x0
 1ae:	450080e7          	jalr	1104(ra) # 5fa <close>
    return;
 1b2:	bf79                	j	150 <ls+0x9c>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 1b4:	854a                	mv	a0,s2
 1b6:	00000097          	auipc	ra,0x0
 1ba:	1f8080e7          	jalr	504(ra) # 3ae <strlen>
 1be:	2541                	addiw	a0,a0,16
 1c0:	20000793          	li	a5,512
 1c4:	00a7fb63          	bgeu	a5,a0,1da <ls+0x126>
      printf("ls: path too long\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	97850513          	addi	a0,a0,-1672 # b40 <malloc+0x134>
 1d0:	00000097          	auipc	ra,0x0
 1d4:	784080e7          	jalr	1924(ra) # 954 <printf>
      break;
 1d8:	b7bd                	j	146 <ls+0x92>
    strcpy(buf, path);
 1da:	85ca                	mv	a1,s2
 1dc:	db040513          	addi	a0,s0,-592
 1e0:	00000097          	auipc	ra,0x0
 1e4:	186080e7          	jalr	390(ra) # 366 <strcpy>
    p = buf+strlen(buf);
 1e8:	db040513          	addi	a0,s0,-592
 1ec:	00000097          	auipc	ra,0x0
 1f0:	1c2080e7          	jalr	450(ra) # 3ae <strlen>
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
 210:	954b0b13          	addi	s6,s6,-1708 # b60 <malloc+0x154>
        printf("%d\t",cont);
 214:	00001a17          	auipc	s4,0x1
 218:	deca0a13          	addi	s4,s4,-532 # 1000 <cont>
 21c:	00001b97          	auipc	s7,0x1
 220:	93cb8b93          	addi	s7,s7,-1732 # b58 <malloc+0x14c>
        printf("ls: cannot stat %s\n", buf);
 224:	00001c17          	auipc	s8,0x1
 228:	8f4c0c13          	addi	s8,s8,-1804 # b18 <malloc+0x10c>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 22c:	a81d                	j	262 <ls+0x1ae>
        printf("ls: cannot stat %s\n", buf);
 22e:	db040593          	addi	a1,s0,-592
 232:	8562                	mv	a0,s8
 234:	00000097          	auipc	ra,0x0
 238:	720080e7          	jalr	1824(ra) # 954 <printf>
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
 25e:	6fa080e7          	jalr	1786(ra) # 954 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 262:	4641                	li	a2,16
 264:	da040593          	addi	a1,s0,-608
 268:	8526                	mv	a0,s1
 26a:	00000097          	auipc	ra,0x0
 26e:	380080e7          	jalr	896(ra) # 5ea <read>
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
 28a:	29a080e7          	jalr	666(ra) # 520 <memmove>
      p[DIRSIZ] = 0;
 28e:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 292:	d8840593          	addi	a1,s0,-632
 296:	db040513          	addi	a0,s0,-592
 29a:	00000097          	auipc	ra,0x0
 29e:	1f8080e7          	jalr	504(ra) # 492 <stat>
 2a2:	f80546e3          	bltz	a0,22e <ls+0x17a>
      if(flag>=1){
 2a6:	f9305ce3          	blez	s3,23e <ls+0x18a>
        printf("%d\t",cont);
 2aa:	000a2583          	lw	a1,0(s4)
 2ae:	855e                	mv	a0,s7
 2b0:	00000097          	auipc	ra,0x0
 2b4:	6a4080e7          	jalr	1700(ra) # 954 <printf>
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
 2d0:	e052                	sd	s4,0(sp)
 2d2:	1800                	addi	s0,sp,48
 2d4:	892a                	mv	s2,a0
 2d6:	8a2e                	mv	s4,a1
  int flag=0;
  int i;

  if(strcmp(argv[1],"-n")==0)
 2d8:	00001597          	auipc	a1,0x1
 2dc:	89858593          	addi	a1,a1,-1896 # b70 <malloc+0x164>
 2e0:	008a3503          	ld	a0,8(s4)
 2e4:	00000097          	auipc	ra,0x0
 2e8:	09e080e7          	jalr	158(ra) # 382 <strcmp>
 2ec:	00153793          	seqz	a5,a0
  int flag=0;
 2f0:	89be                	mv	s3,a5
  {
    flag+=1;
  }
  if(argc < 2+flag){
 2f2:	00178493          	addi	s1,a5,1
 2f6:	0324dd63          	bge	s1,s2,330 <main+0x6c>
    ls(".",flag);
    exit(0);
  }
  for(i=flag+1; i<argc; i++)
 2fa:	048e                	slli	s1,s1,0x3
 2fc:	94d2                	add	s1,s1,s4
 2fe:	3979                	addiw	s2,s2,-2
 300:	40f9093b          	subw	s2,s2,a5
 304:	1902                	slli	s2,s2,0x20
 306:	02095913          	srli	s2,s2,0x20
 30a:	993e                	add	s2,s2,a5
 30c:	090e                	slli	s2,s2,0x3
 30e:	010a0593          	addi	a1,s4,16
 312:	992e                	add	s2,s2,a1
    ls(argv[i],flag);
 314:	85ce                	mv	a1,s3
 316:	6088                	ld	a0,0(s1)
 318:	00000097          	auipc	ra,0x0
 31c:	d9c080e7          	jalr	-612(ra) # b4 <ls>
  for(i=flag+1; i<argc; i++)
 320:	04a1                	addi	s1,s1,8
 322:	ff2499e3          	bne	s1,s2,314 <main+0x50>
  exit(0);
 326:	4501                	li	a0,0
 328:	00000097          	auipc	ra,0x0
 32c:	2aa080e7          	jalr	682(ra) # 5d2 <exit>
    ls(".",flag);
 330:	85be                	mv	a1,a5
 332:	00001517          	auipc	a0,0x1
 336:	84650513          	addi	a0,a0,-1978 # b78 <malloc+0x16c>
 33a:	00000097          	auipc	ra,0x0
 33e:	d7a080e7          	jalr	-646(ra) # b4 <ls>
    exit(0);
 342:	4501                	li	a0,0
 344:	00000097          	auipc	ra,0x0
 348:	28e080e7          	jalr	654(ra) # 5d2 <exit>

000000000000034c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e406                	sd	ra,8(sp)
 350:	e022                	sd	s0,0(sp)
 352:	0800                	addi	s0,sp,16
  extern int main();
  main();
 354:	00000097          	auipc	ra,0x0
 358:	f70080e7          	jalr	-144(ra) # 2c4 <main>
  exit(0);
 35c:	4501                	li	a0,0
 35e:	00000097          	auipc	ra,0x0
 362:	274080e7          	jalr	628(ra) # 5d2 <exit>

0000000000000366 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 366:	1141                	addi	sp,sp,-16
 368:	e422                	sd	s0,8(sp)
 36a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 36c:	87aa                	mv	a5,a0
 36e:	0585                	addi	a1,a1,1
 370:	0785                	addi	a5,a5,1
 372:	fff5c703          	lbu	a4,-1(a1)
 376:	fee78fa3          	sb	a4,-1(a5)
 37a:	fb75                	bnez	a4,36e <strcpy+0x8>
    ;
  return os;
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret

0000000000000382 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 382:	1141                	addi	sp,sp,-16
 384:	e422                	sd	s0,8(sp)
 386:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 388:	00054783          	lbu	a5,0(a0)
 38c:	cb91                	beqz	a5,3a0 <strcmp+0x1e>
 38e:	0005c703          	lbu	a4,0(a1)
 392:	00f71763          	bne	a4,a5,3a0 <strcmp+0x1e>
    p++, q++;
 396:	0505                	addi	a0,a0,1
 398:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 39a:	00054783          	lbu	a5,0(a0)
 39e:	fbe5                	bnez	a5,38e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3a0:	0005c503          	lbu	a0,0(a1)
}
 3a4:	40a7853b          	subw	a0,a5,a0
 3a8:	6422                	ld	s0,8(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret

00000000000003ae <strlen>:

uint
strlen(const char *s)
{
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e422                	sd	s0,8(sp)
 3b2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3b4:	00054783          	lbu	a5,0(a0)
 3b8:	cf91                	beqz	a5,3d4 <strlen+0x26>
 3ba:	0505                	addi	a0,a0,1
 3bc:	87aa                	mv	a5,a0
 3be:	4685                	li	a3,1
 3c0:	9e89                	subw	a3,a3,a0
 3c2:	00f6853b          	addw	a0,a3,a5
 3c6:	0785                	addi	a5,a5,1
 3c8:	fff7c703          	lbu	a4,-1(a5)
 3cc:	fb7d                	bnez	a4,3c2 <strlen+0x14>
    ;
  return n;
}
 3ce:	6422                	ld	s0,8(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret
  for(n = 0; s[n]; n++)
 3d4:	4501                	li	a0,0
 3d6:	bfe5                	j	3ce <strlen+0x20>

00000000000003d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e422                	sd	s0,8(sp)
 3dc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3de:	ca19                	beqz	a2,3f4 <memset+0x1c>
 3e0:	87aa                	mv	a5,a0
 3e2:	1602                	slli	a2,a2,0x20
 3e4:	9201                	srli	a2,a2,0x20
 3e6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3ea:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3ee:	0785                	addi	a5,a5,1
 3f0:	fee79de3          	bne	a5,a4,3ea <memset+0x12>
  }
  return dst;
}
 3f4:	6422                	ld	s0,8(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret

00000000000003fa <strchr>:

char*
strchr(const char *s, char c)
{
 3fa:	1141                	addi	sp,sp,-16
 3fc:	e422                	sd	s0,8(sp)
 3fe:	0800                	addi	s0,sp,16
  for(; *s; s++)
 400:	00054783          	lbu	a5,0(a0)
 404:	cb99                	beqz	a5,41a <strchr+0x20>
    if(*s == c)
 406:	00f58763          	beq	a1,a5,414 <strchr+0x1a>
  for(; *s; s++)
 40a:	0505                	addi	a0,a0,1
 40c:	00054783          	lbu	a5,0(a0)
 410:	fbfd                	bnez	a5,406 <strchr+0xc>
      return (char*)s;
  return 0;
 412:	4501                	li	a0,0
}
 414:	6422                	ld	s0,8(sp)
 416:	0141                	addi	sp,sp,16
 418:	8082                	ret
  return 0;
 41a:	4501                	li	a0,0
 41c:	bfe5                	j	414 <strchr+0x1a>

000000000000041e <gets>:

char*
gets(char *buf, int max)
{
 41e:	711d                	addi	sp,sp,-96
 420:	ec86                	sd	ra,88(sp)
 422:	e8a2                	sd	s0,80(sp)
 424:	e4a6                	sd	s1,72(sp)
 426:	e0ca                	sd	s2,64(sp)
 428:	fc4e                	sd	s3,56(sp)
 42a:	f852                	sd	s4,48(sp)
 42c:	f456                	sd	s5,40(sp)
 42e:	f05a                	sd	s6,32(sp)
 430:	ec5e                	sd	s7,24(sp)
 432:	1080                	addi	s0,sp,96
 434:	8baa                	mv	s7,a0
 436:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 438:	892a                	mv	s2,a0
 43a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 43c:	4aa9                	li	s5,10
 43e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 440:	89a6                	mv	s3,s1
 442:	2485                	addiw	s1,s1,1
 444:	0344d863          	bge	s1,s4,474 <gets+0x56>
    cc = read(0, &c, 1);
 448:	4605                	li	a2,1
 44a:	faf40593          	addi	a1,s0,-81
 44e:	4501                	li	a0,0
 450:	00000097          	auipc	ra,0x0
 454:	19a080e7          	jalr	410(ra) # 5ea <read>
    if(cc < 1)
 458:	00a05e63          	blez	a0,474 <gets+0x56>
    buf[i++] = c;
 45c:	faf44783          	lbu	a5,-81(s0)
 460:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 464:	01578763          	beq	a5,s5,472 <gets+0x54>
 468:	0905                	addi	s2,s2,1
 46a:	fd679be3          	bne	a5,s6,440 <gets+0x22>
  for(i=0; i+1 < max; ){
 46e:	89a6                	mv	s3,s1
 470:	a011                	j	474 <gets+0x56>
 472:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 474:	99de                	add	s3,s3,s7
 476:	00098023          	sb	zero,0(s3)
  return buf;
}
 47a:	855e                	mv	a0,s7
 47c:	60e6                	ld	ra,88(sp)
 47e:	6446                	ld	s0,80(sp)
 480:	64a6                	ld	s1,72(sp)
 482:	6906                	ld	s2,64(sp)
 484:	79e2                	ld	s3,56(sp)
 486:	7a42                	ld	s4,48(sp)
 488:	7aa2                	ld	s5,40(sp)
 48a:	7b02                	ld	s6,32(sp)
 48c:	6be2                	ld	s7,24(sp)
 48e:	6125                	addi	sp,sp,96
 490:	8082                	ret

0000000000000492 <stat>:

int
stat(const char *n, struct stat *st)
{
 492:	1101                	addi	sp,sp,-32
 494:	ec06                	sd	ra,24(sp)
 496:	e822                	sd	s0,16(sp)
 498:	e426                	sd	s1,8(sp)
 49a:	e04a                	sd	s2,0(sp)
 49c:	1000                	addi	s0,sp,32
 49e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4a0:	4581                	li	a1,0
 4a2:	00000097          	auipc	ra,0x0
 4a6:	170080e7          	jalr	368(ra) # 612 <open>
  if(fd < 0)
 4aa:	02054563          	bltz	a0,4d4 <stat+0x42>
 4ae:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4b0:	85ca                	mv	a1,s2
 4b2:	00000097          	auipc	ra,0x0
 4b6:	178080e7          	jalr	376(ra) # 62a <fstat>
 4ba:	892a                	mv	s2,a0
  close(fd);
 4bc:	8526                	mv	a0,s1
 4be:	00000097          	auipc	ra,0x0
 4c2:	13c080e7          	jalr	316(ra) # 5fa <close>
  return r;
}
 4c6:	854a                	mv	a0,s2
 4c8:	60e2                	ld	ra,24(sp)
 4ca:	6442                	ld	s0,16(sp)
 4cc:	64a2                	ld	s1,8(sp)
 4ce:	6902                	ld	s2,0(sp)
 4d0:	6105                	addi	sp,sp,32
 4d2:	8082                	ret
    return -1;
 4d4:	597d                	li	s2,-1
 4d6:	bfc5                	j	4c6 <stat+0x34>

00000000000004d8 <atoi>:

int
atoi(const char *s)
{
 4d8:	1141                	addi	sp,sp,-16
 4da:	e422                	sd	s0,8(sp)
 4dc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4de:	00054683          	lbu	a3,0(a0)
 4e2:	fd06879b          	addiw	a5,a3,-48
 4e6:	0ff7f793          	zext.b	a5,a5
 4ea:	4625                	li	a2,9
 4ec:	02f66863          	bltu	a2,a5,51c <atoi+0x44>
 4f0:	872a                	mv	a4,a0
  n = 0;
 4f2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 4f4:	0705                	addi	a4,a4,1
 4f6:	0025179b          	slliw	a5,a0,0x2
 4fa:	9fa9                	addw	a5,a5,a0
 4fc:	0017979b          	slliw	a5,a5,0x1
 500:	9fb5                	addw	a5,a5,a3
 502:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 506:	00074683          	lbu	a3,0(a4)
 50a:	fd06879b          	addiw	a5,a3,-48
 50e:	0ff7f793          	zext.b	a5,a5
 512:	fef671e3          	bgeu	a2,a5,4f4 <atoi+0x1c>
  return n;
}
 516:	6422                	ld	s0,8(sp)
 518:	0141                	addi	sp,sp,16
 51a:	8082                	ret
  n = 0;
 51c:	4501                	li	a0,0
 51e:	bfe5                	j	516 <atoi+0x3e>

0000000000000520 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 520:	1141                	addi	sp,sp,-16
 522:	e422                	sd	s0,8(sp)
 524:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 526:	02b57463          	bgeu	a0,a1,54e <memmove+0x2e>
    while(n-- > 0)
 52a:	00c05f63          	blez	a2,548 <memmove+0x28>
 52e:	1602                	slli	a2,a2,0x20
 530:	9201                	srli	a2,a2,0x20
 532:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 536:	872a                	mv	a4,a0
      *dst++ = *src++;
 538:	0585                	addi	a1,a1,1
 53a:	0705                	addi	a4,a4,1
 53c:	fff5c683          	lbu	a3,-1(a1)
 540:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 544:	fee79ae3          	bne	a5,a4,538 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 548:	6422                	ld	s0,8(sp)
 54a:	0141                	addi	sp,sp,16
 54c:	8082                	ret
    dst += n;
 54e:	00c50733          	add	a4,a0,a2
    src += n;
 552:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 554:	fec05ae3          	blez	a2,548 <memmove+0x28>
 558:	fff6079b          	addiw	a5,a2,-1
 55c:	1782                	slli	a5,a5,0x20
 55e:	9381                	srli	a5,a5,0x20
 560:	fff7c793          	not	a5,a5
 564:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 566:	15fd                	addi	a1,a1,-1
 568:	177d                	addi	a4,a4,-1
 56a:	0005c683          	lbu	a3,0(a1)
 56e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 572:	fee79ae3          	bne	a5,a4,566 <memmove+0x46>
 576:	bfc9                	j	548 <memmove+0x28>

0000000000000578 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 578:	1141                	addi	sp,sp,-16
 57a:	e422                	sd	s0,8(sp)
 57c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 57e:	ca05                	beqz	a2,5ae <memcmp+0x36>
 580:	fff6069b          	addiw	a3,a2,-1
 584:	1682                	slli	a3,a3,0x20
 586:	9281                	srli	a3,a3,0x20
 588:	0685                	addi	a3,a3,1
 58a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 58c:	00054783          	lbu	a5,0(a0)
 590:	0005c703          	lbu	a4,0(a1)
 594:	00e79863          	bne	a5,a4,5a4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 598:	0505                	addi	a0,a0,1
    p2++;
 59a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 59c:	fed518e3          	bne	a0,a3,58c <memcmp+0x14>
  }
  return 0;
 5a0:	4501                	li	a0,0
 5a2:	a019                	j	5a8 <memcmp+0x30>
      return *p1 - *p2;
 5a4:	40e7853b          	subw	a0,a5,a4
}
 5a8:	6422                	ld	s0,8(sp)
 5aa:	0141                	addi	sp,sp,16
 5ac:	8082                	ret
  return 0;
 5ae:	4501                	li	a0,0
 5b0:	bfe5                	j	5a8 <memcmp+0x30>

00000000000005b2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5b2:	1141                	addi	sp,sp,-16
 5b4:	e406                	sd	ra,8(sp)
 5b6:	e022                	sd	s0,0(sp)
 5b8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5ba:	00000097          	auipc	ra,0x0
 5be:	f66080e7          	jalr	-154(ra) # 520 <memmove>
}
 5c2:	60a2                	ld	ra,8(sp)
 5c4:	6402                	ld	s0,0(sp)
 5c6:	0141                	addi	sp,sp,16
 5c8:	8082                	ret

00000000000005ca <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5ca:	4885                	li	a7,1
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5d2:	4889                	li	a7,2
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <wait>:
.global wait
wait:
 li a7, SYS_wait
 5da:	488d                	li	a7,3
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5e2:	4891                	li	a7,4
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <read>:
.global read
read:
 li a7, SYS_read
 5ea:	4895                	li	a7,5
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <write>:
.global write
write:
 li a7, SYS_write
 5f2:	48c1                	li	a7,16
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <close>:
.global close
close:
 li a7, SYS_close
 5fa:	48d5                	li	a7,21
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <kill>:
.global kill
kill:
 li a7, SYS_kill
 602:	4899                	li	a7,6
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <exec>:
.global exec
exec:
 li a7, SYS_exec
 60a:	489d                	li	a7,7
 ecall
 60c:	00000073          	ecall
 ret
 610:	8082                	ret

0000000000000612 <open>:
.global open
open:
 li a7, SYS_open
 612:	48bd                	li	a7,15
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 61a:	48c5                	li	a7,17
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 622:	48c9                	li	a7,18
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 62a:	48a1                	li	a7,8
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <link>:
.global link
link:
 li a7, SYS_link
 632:	48cd                	li	a7,19
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 63a:	48d1                	li	a7,20
 ecall
 63c:	00000073          	ecall
 ret
 640:	8082                	ret

0000000000000642 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 642:	48a5                	li	a7,9
 ecall
 644:	00000073          	ecall
 ret
 648:	8082                	ret

000000000000064a <dup>:
.global dup
dup:
 li a7, SYS_dup
 64a:	48a9                	li	a7,10
 ecall
 64c:	00000073          	ecall
 ret
 650:	8082                	ret

0000000000000652 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 652:	48ad                	li	a7,11
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 65a:	48b1                	li	a7,12
 ecall
 65c:	00000073          	ecall
 ret
 660:	8082                	ret

0000000000000662 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 662:	48b5                	li	a7,13
 ecall
 664:	00000073          	ecall
 ret
 668:	8082                	ret

000000000000066a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 66a:	48b9                	li	a7,14
 ecall
 66c:	00000073          	ecall
 ret
 670:	8082                	ret

0000000000000672 <cow>:
.global cow
cow:
 li a7, SYS_cow
 672:	48d9                	li	a7,22
 ecall
 674:	00000073          	ecall
 ret
 678:	8082                	ret

000000000000067a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 67a:	1101                	addi	sp,sp,-32
 67c:	ec06                	sd	ra,24(sp)
 67e:	e822                	sd	s0,16(sp)
 680:	1000                	addi	s0,sp,32
 682:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 686:	4605                	li	a2,1
 688:	fef40593          	addi	a1,s0,-17
 68c:	00000097          	auipc	ra,0x0
 690:	f66080e7          	jalr	-154(ra) # 5f2 <write>
}
 694:	60e2                	ld	ra,24(sp)
 696:	6442                	ld	s0,16(sp)
 698:	6105                	addi	sp,sp,32
 69a:	8082                	ret

000000000000069c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 69c:	7139                	addi	sp,sp,-64
 69e:	fc06                	sd	ra,56(sp)
 6a0:	f822                	sd	s0,48(sp)
 6a2:	f426                	sd	s1,40(sp)
 6a4:	f04a                	sd	s2,32(sp)
 6a6:	ec4e                	sd	s3,24(sp)
 6a8:	0080                	addi	s0,sp,64
 6aa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6ac:	c299                	beqz	a3,6b2 <printint+0x16>
 6ae:	0805c963          	bltz	a1,740 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6b2:	2581                	sext.w	a1,a1
  neg = 0;
 6b4:	4881                	li	a7,0
 6b6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6ba:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6bc:	2601                	sext.w	a2,a2
 6be:	00000517          	auipc	a0,0x0
 6c2:	52250513          	addi	a0,a0,1314 # be0 <digits>
 6c6:	883a                	mv	a6,a4
 6c8:	2705                	addiw	a4,a4,1
 6ca:	02c5f7bb          	remuw	a5,a1,a2
 6ce:	1782                	slli	a5,a5,0x20
 6d0:	9381                	srli	a5,a5,0x20
 6d2:	97aa                	add	a5,a5,a0
 6d4:	0007c783          	lbu	a5,0(a5)
 6d8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6dc:	0005879b          	sext.w	a5,a1
 6e0:	02c5d5bb          	divuw	a1,a1,a2
 6e4:	0685                	addi	a3,a3,1
 6e6:	fec7f0e3          	bgeu	a5,a2,6c6 <printint+0x2a>
  if(neg)
 6ea:	00088c63          	beqz	a7,702 <printint+0x66>
    buf[i++] = '-';
 6ee:	fd070793          	addi	a5,a4,-48
 6f2:	00878733          	add	a4,a5,s0
 6f6:	02d00793          	li	a5,45
 6fa:	fef70823          	sb	a5,-16(a4)
 6fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 702:	02e05863          	blez	a4,732 <printint+0x96>
 706:	fc040793          	addi	a5,s0,-64
 70a:	00e78933          	add	s2,a5,a4
 70e:	fff78993          	addi	s3,a5,-1
 712:	99ba                	add	s3,s3,a4
 714:	377d                	addiw	a4,a4,-1
 716:	1702                	slli	a4,a4,0x20
 718:	9301                	srli	a4,a4,0x20
 71a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 71e:	fff94583          	lbu	a1,-1(s2)
 722:	8526                	mv	a0,s1
 724:	00000097          	auipc	ra,0x0
 728:	f56080e7          	jalr	-170(ra) # 67a <putc>
  while(--i >= 0)
 72c:	197d                	addi	s2,s2,-1
 72e:	ff3918e3          	bne	s2,s3,71e <printint+0x82>
}
 732:	70e2                	ld	ra,56(sp)
 734:	7442                	ld	s0,48(sp)
 736:	74a2                	ld	s1,40(sp)
 738:	7902                	ld	s2,32(sp)
 73a:	69e2                	ld	s3,24(sp)
 73c:	6121                	addi	sp,sp,64
 73e:	8082                	ret
    x = -xx;
 740:	40b005bb          	negw	a1,a1
    neg = 1;
 744:	4885                	li	a7,1
    x = -xx;
 746:	bf85                	j	6b6 <printint+0x1a>

0000000000000748 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 748:	7119                	addi	sp,sp,-128
 74a:	fc86                	sd	ra,120(sp)
 74c:	f8a2                	sd	s0,112(sp)
 74e:	f4a6                	sd	s1,104(sp)
 750:	f0ca                	sd	s2,96(sp)
 752:	ecce                	sd	s3,88(sp)
 754:	e8d2                	sd	s4,80(sp)
 756:	e4d6                	sd	s5,72(sp)
 758:	e0da                	sd	s6,64(sp)
 75a:	fc5e                	sd	s7,56(sp)
 75c:	f862                	sd	s8,48(sp)
 75e:	f466                	sd	s9,40(sp)
 760:	f06a                	sd	s10,32(sp)
 762:	ec6e                	sd	s11,24(sp)
 764:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 766:	0005c903          	lbu	s2,0(a1)
 76a:	18090f63          	beqz	s2,908 <vprintf+0x1c0>
 76e:	8aaa                	mv	s5,a0
 770:	8b32                	mv	s6,a2
 772:	00158493          	addi	s1,a1,1
  state = 0;
 776:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 778:	02500a13          	li	s4,37
 77c:	4c55                	li	s8,21
 77e:	00000c97          	auipc	s9,0x0
 782:	40ac8c93          	addi	s9,s9,1034 # b88 <malloc+0x17c>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 786:	02800d93          	li	s11,40
  putc(fd, 'x');
 78a:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 78c:	00000b97          	auipc	s7,0x0
 790:	454b8b93          	addi	s7,s7,1108 # be0 <digits>
 794:	a839                	j	7b2 <vprintf+0x6a>
        putc(fd, c);
 796:	85ca                	mv	a1,s2
 798:	8556                	mv	a0,s5
 79a:	00000097          	auipc	ra,0x0
 79e:	ee0080e7          	jalr	-288(ra) # 67a <putc>
 7a2:	a019                	j	7a8 <vprintf+0x60>
    } else if(state == '%'){
 7a4:	01498d63          	beq	s3,s4,7be <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 7a8:	0485                	addi	s1,s1,1
 7aa:	fff4c903          	lbu	s2,-1(s1)
 7ae:	14090d63          	beqz	s2,908 <vprintf+0x1c0>
    if(state == 0){
 7b2:	fe0999e3          	bnez	s3,7a4 <vprintf+0x5c>
      if(c == '%'){
 7b6:	ff4910e3          	bne	s2,s4,796 <vprintf+0x4e>
        state = '%';
 7ba:	89d2                	mv	s3,s4
 7bc:	b7f5                	j	7a8 <vprintf+0x60>
      if(c == 'd'){
 7be:	11490c63          	beq	s2,s4,8d6 <vprintf+0x18e>
 7c2:	f9d9079b          	addiw	a5,s2,-99
 7c6:	0ff7f793          	zext.b	a5,a5
 7ca:	10fc6e63          	bltu	s8,a5,8e6 <vprintf+0x19e>
 7ce:	f9d9079b          	addiw	a5,s2,-99
 7d2:	0ff7f713          	zext.b	a4,a5
 7d6:	10ec6863          	bltu	s8,a4,8e6 <vprintf+0x19e>
 7da:	00271793          	slli	a5,a4,0x2
 7de:	97e6                	add	a5,a5,s9
 7e0:	439c                	lw	a5,0(a5)
 7e2:	97e6                	add	a5,a5,s9
 7e4:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 7e6:	008b0913          	addi	s2,s6,8
 7ea:	4685                	li	a3,1
 7ec:	4629                	li	a2,10
 7ee:	000b2583          	lw	a1,0(s6)
 7f2:	8556                	mv	a0,s5
 7f4:	00000097          	auipc	ra,0x0
 7f8:	ea8080e7          	jalr	-344(ra) # 69c <printint>
 7fc:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 7fe:	4981                	li	s3,0
 800:	b765                	j	7a8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 802:	008b0913          	addi	s2,s6,8
 806:	4681                	li	a3,0
 808:	4629                	li	a2,10
 80a:	000b2583          	lw	a1,0(s6)
 80e:	8556                	mv	a0,s5
 810:	00000097          	auipc	ra,0x0
 814:	e8c080e7          	jalr	-372(ra) # 69c <printint>
 818:	8b4a                	mv	s6,s2
      state = 0;
 81a:	4981                	li	s3,0
 81c:	b771                	j	7a8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 81e:	008b0913          	addi	s2,s6,8
 822:	4681                	li	a3,0
 824:	866a                	mv	a2,s10
 826:	000b2583          	lw	a1,0(s6)
 82a:	8556                	mv	a0,s5
 82c:	00000097          	auipc	ra,0x0
 830:	e70080e7          	jalr	-400(ra) # 69c <printint>
 834:	8b4a                	mv	s6,s2
      state = 0;
 836:	4981                	li	s3,0
 838:	bf85                	j	7a8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 83a:	008b0793          	addi	a5,s6,8
 83e:	f8f43423          	sd	a5,-120(s0)
 842:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 846:	03000593          	li	a1,48
 84a:	8556                	mv	a0,s5
 84c:	00000097          	auipc	ra,0x0
 850:	e2e080e7          	jalr	-466(ra) # 67a <putc>
  putc(fd, 'x');
 854:	07800593          	li	a1,120
 858:	8556                	mv	a0,s5
 85a:	00000097          	auipc	ra,0x0
 85e:	e20080e7          	jalr	-480(ra) # 67a <putc>
 862:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 864:	03c9d793          	srli	a5,s3,0x3c
 868:	97de                	add	a5,a5,s7
 86a:	0007c583          	lbu	a1,0(a5)
 86e:	8556                	mv	a0,s5
 870:	00000097          	auipc	ra,0x0
 874:	e0a080e7          	jalr	-502(ra) # 67a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 878:	0992                	slli	s3,s3,0x4
 87a:	397d                	addiw	s2,s2,-1
 87c:	fe0914e3          	bnez	s2,864 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 880:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 884:	4981                	li	s3,0
 886:	b70d                	j	7a8 <vprintf+0x60>
        s = va_arg(ap, char*);
 888:	008b0913          	addi	s2,s6,8
 88c:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 890:	02098163          	beqz	s3,8b2 <vprintf+0x16a>
        while(*s != 0){
 894:	0009c583          	lbu	a1,0(s3)
 898:	c5ad                	beqz	a1,902 <vprintf+0x1ba>
          putc(fd, *s);
 89a:	8556                	mv	a0,s5
 89c:	00000097          	auipc	ra,0x0
 8a0:	dde080e7          	jalr	-546(ra) # 67a <putc>
          s++;
 8a4:	0985                	addi	s3,s3,1
        while(*s != 0){
 8a6:	0009c583          	lbu	a1,0(s3)
 8aa:	f9e5                	bnez	a1,89a <vprintf+0x152>
        s = va_arg(ap, char*);
 8ac:	8b4a                	mv	s6,s2
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	bde5                	j	7a8 <vprintf+0x60>
          s = "(null)";
 8b2:	00000997          	auipc	s3,0x0
 8b6:	2ce98993          	addi	s3,s3,718 # b80 <malloc+0x174>
        while(*s != 0){
 8ba:	85ee                	mv	a1,s11
 8bc:	bff9                	j	89a <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 8be:	008b0913          	addi	s2,s6,8
 8c2:	000b4583          	lbu	a1,0(s6)
 8c6:	8556                	mv	a0,s5
 8c8:	00000097          	auipc	ra,0x0
 8cc:	db2080e7          	jalr	-590(ra) # 67a <putc>
 8d0:	8b4a                	mv	s6,s2
      state = 0;
 8d2:	4981                	li	s3,0
 8d4:	bdd1                	j	7a8 <vprintf+0x60>
        putc(fd, c);
 8d6:	85d2                	mv	a1,s4
 8d8:	8556                	mv	a0,s5
 8da:	00000097          	auipc	ra,0x0
 8de:	da0080e7          	jalr	-608(ra) # 67a <putc>
      state = 0;
 8e2:	4981                	li	s3,0
 8e4:	b5d1                	j	7a8 <vprintf+0x60>
        putc(fd, '%');
 8e6:	85d2                	mv	a1,s4
 8e8:	8556                	mv	a0,s5
 8ea:	00000097          	auipc	ra,0x0
 8ee:	d90080e7          	jalr	-624(ra) # 67a <putc>
        putc(fd, c);
 8f2:	85ca                	mv	a1,s2
 8f4:	8556                	mv	a0,s5
 8f6:	00000097          	auipc	ra,0x0
 8fa:	d84080e7          	jalr	-636(ra) # 67a <putc>
      state = 0;
 8fe:	4981                	li	s3,0
 900:	b565                	j	7a8 <vprintf+0x60>
        s = va_arg(ap, char*);
 902:	8b4a                	mv	s6,s2
      state = 0;
 904:	4981                	li	s3,0
 906:	b54d                	j	7a8 <vprintf+0x60>
    }
  }
}
 908:	70e6                	ld	ra,120(sp)
 90a:	7446                	ld	s0,112(sp)
 90c:	74a6                	ld	s1,104(sp)
 90e:	7906                	ld	s2,96(sp)
 910:	69e6                	ld	s3,88(sp)
 912:	6a46                	ld	s4,80(sp)
 914:	6aa6                	ld	s5,72(sp)
 916:	6b06                	ld	s6,64(sp)
 918:	7be2                	ld	s7,56(sp)
 91a:	7c42                	ld	s8,48(sp)
 91c:	7ca2                	ld	s9,40(sp)
 91e:	7d02                	ld	s10,32(sp)
 920:	6de2                	ld	s11,24(sp)
 922:	6109                	addi	sp,sp,128
 924:	8082                	ret

0000000000000926 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 926:	715d                	addi	sp,sp,-80
 928:	ec06                	sd	ra,24(sp)
 92a:	e822                	sd	s0,16(sp)
 92c:	1000                	addi	s0,sp,32
 92e:	e010                	sd	a2,0(s0)
 930:	e414                	sd	a3,8(s0)
 932:	e818                	sd	a4,16(s0)
 934:	ec1c                	sd	a5,24(s0)
 936:	03043023          	sd	a6,32(s0)
 93a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 93e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 942:	8622                	mv	a2,s0
 944:	00000097          	auipc	ra,0x0
 948:	e04080e7          	jalr	-508(ra) # 748 <vprintf>
}
 94c:	60e2                	ld	ra,24(sp)
 94e:	6442                	ld	s0,16(sp)
 950:	6161                	addi	sp,sp,80
 952:	8082                	ret

0000000000000954 <printf>:

void
printf(const char *fmt, ...)
{
 954:	711d                	addi	sp,sp,-96
 956:	ec06                	sd	ra,24(sp)
 958:	e822                	sd	s0,16(sp)
 95a:	1000                	addi	s0,sp,32
 95c:	e40c                	sd	a1,8(s0)
 95e:	e810                	sd	a2,16(s0)
 960:	ec14                	sd	a3,24(s0)
 962:	f018                	sd	a4,32(s0)
 964:	f41c                	sd	a5,40(s0)
 966:	03043823          	sd	a6,48(s0)
 96a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 96e:	00840613          	addi	a2,s0,8
 972:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 976:	85aa                	mv	a1,a0
 978:	4505                	li	a0,1
 97a:	00000097          	auipc	ra,0x0
 97e:	dce080e7          	jalr	-562(ra) # 748 <vprintf>
}
 982:	60e2                	ld	ra,24(sp)
 984:	6442                	ld	s0,16(sp)
 986:	6125                	addi	sp,sp,96
 988:	8082                	ret

000000000000098a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 98a:	1141                	addi	sp,sp,-16
 98c:	e422                	sd	s0,8(sp)
 98e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 990:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 994:	00000797          	auipc	a5,0x0
 998:	67c7b783          	ld	a5,1660(a5) # 1010 <freep>
 99c:	a02d                	j	9c6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 99e:	4618                	lw	a4,8(a2)
 9a0:	9f2d                	addw	a4,a4,a1
 9a2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9a6:	6398                	ld	a4,0(a5)
 9a8:	6310                	ld	a2,0(a4)
 9aa:	a83d                	j	9e8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9ac:	ff852703          	lw	a4,-8(a0)
 9b0:	9f31                	addw	a4,a4,a2
 9b2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9b4:	ff053683          	ld	a3,-16(a0)
 9b8:	a091                	j	9fc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ba:	6398                	ld	a4,0(a5)
 9bc:	00e7e463          	bltu	a5,a4,9c4 <free+0x3a>
 9c0:	00e6ea63          	bltu	a3,a4,9d4 <free+0x4a>
{
 9c4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c6:	fed7fae3          	bgeu	a5,a3,9ba <free+0x30>
 9ca:	6398                	ld	a4,0(a5)
 9cc:	00e6e463          	bltu	a3,a4,9d4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9d0:	fee7eae3          	bltu	a5,a4,9c4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 9d4:	ff852583          	lw	a1,-8(a0)
 9d8:	6390                	ld	a2,0(a5)
 9da:	02059813          	slli	a6,a1,0x20
 9de:	01c85713          	srli	a4,a6,0x1c
 9e2:	9736                	add	a4,a4,a3
 9e4:	fae60de3          	beq	a2,a4,99e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9e8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9ec:	4790                	lw	a2,8(a5)
 9ee:	02061593          	slli	a1,a2,0x20
 9f2:	01c5d713          	srli	a4,a1,0x1c
 9f6:	973e                	add	a4,a4,a5
 9f8:	fae68ae3          	beq	a3,a4,9ac <free+0x22>
    p->s.ptr = bp->s.ptr;
 9fc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9fe:	00000717          	auipc	a4,0x0
 a02:	60f73923          	sd	a5,1554(a4) # 1010 <freep>
}
 a06:	6422                	ld	s0,8(sp)
 a08:	0141                	addi	sp,sp,16
 a0a:	8082                	ret

0000000000000a0c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a0c:	7139                	addi	sp,sp,-64
 a0e:	fc06                	sd	ra,56(sp)
 a10:	f822                	sd	s0,48(sp)
 a12:	f426                	sd	s1,40(sp)
 a14:	f04a                	sd	s2,32(sp)
 a16:	ec4e                	sd	s3,24(sp)
 a18:	e852                	sd	s4,16(sp)
 a1a:	e456                	sd	s5,8(sp)
 a1c:	e05a                	sd	s6,0(sp)
 a1e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a20:	02051493          	slli	s1,a0,0x20
 a24:	9081                	srli	s1,s1,0x20
 a26:	04bd                	addi	s1,s1,15
 a28:	8091                	srli	s1,s1,0x4
 a2a:	0014899b          	addiw	s3,s1,1
 a2e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a30:	00000517          	auipc	a0,0x0
 a34:	5e053503          	ld	a0,1504(a0) # 1010 <freep>
 a38:	c515                	beqz	a0,a64 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a3c:	4798                	lw	a4,8(a5)
 a3e:	02977f63          	bgeu	a4,s1,a7c <malloc+0x70>
 a42:	8a4e                	mv	s4,s3
 a44:	0009871b          	sext.w	a4,s3
 a48:	6685                	lui	a3,0x1
 a4a:	00d77363          	bgeu	a4,a3,a50 <malloc+0x44>
 a4e:	6a05                	lui	s4,0x1
 a50:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a54:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a58:	00000917          	auipc	s2,0x0
 a5c:	5b890913          	addi	s2,s2,1464 # 1010 <freep>
  if(p == (char*)-1)
 a60:	5afd                	li	s5,-1
 a62:	a895                	j	ad6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a64:	00000797          	auipc	a5,0x0
 a68:	5cc78793          	addi	a5,a5,1484 # 1030 <base>
 a6c:	00000717          	auipc	a4,0x0
 a70:	5af73223          	sd	a5,1444(a4) # 1010 <freep>
 a74:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a76:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a7a:	b7e1                	j	a42 <malloc+0x36>
      if(p->s.size == nunits)
 a7c:	02e48c63          	beq	s1,a4,ab4 <malloc+0xa8>
        p->s.size -= nunits;
 a80:	4137073b          	subw	a4,a4,s3
 a84:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a86:	02071693          	slli	a3,a4,0x20
 a8a:	01c6d713          	srli	a4,a3,0x1c
 a8e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a90:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a94:	00000717          	auipc	a4,0x0
 a98:	56a73e23          	sd	a0,1404(a4) # 1010 <freep>
      return (void*)(p + 1);
 a9c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 aa0:	70e2                	ld	ra,56(sp)
 aa2:	7442                	ld	s0,48(sp)
 aa4:	74a2                	ld	s1,40(sp)
 aa6:	7902                	ld	s2,32(sp)
 aa8:	69e2                	ld	s3,24(sp)
 aaa:	6a42                	ld	s4,16(sp)
 aac:	6aa2                	ld	s5,8(sp)
 aae:	6b02                	ld	s6,0(sp)
 ab0:	6121                	addi	sp,sp,64
 ab2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ab4:	6398                	ld	a4,0(a5)
 ab6:	e118                	sd	a4,0(a0)
 ab8:	bff1                	j	a94 <malloc+0x88>
  hp->s.size = nu;
 aba:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 abe:	0541                	addi	a0,a0,16
 ac0:	00000097          	auipc	ra,0x0
 ac4:	eca080e7          	jalr	-310(ra) # 98a <free>
  return freep;
 ac8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 acc:	d971                	beqz	a0,aa0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ace:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ad0:	4798                	lw	a4,8(a5)
 ad2:	fa9775e3          	bgeu	a4,s1,a7c <malloc+0x70>
    if(p == freep)
 ad6:	00093703          	ld	a4,0(s2)
 ada:	853e                	mv	a0,a5
 adc:	fef719e3          	bne	a4,a5,ace <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 ae0:	8552                	mv	a0,s4
 ae2:	00000097          	auipc	ra,0x0
 ae6:	b78080e7          	jalr	-1160(ra) # 65a <sbrk>
  if(p == (char*)-1)
 aea:	fd5518e3          	bne	a0,s5,aba <malloc+0xae>
        return 0;
 aee:	4501                	li	a0,0
 af0:	bf45                	j	aa0 <malloc+0x94>
