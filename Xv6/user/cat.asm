
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <numcat>:
char buf[512];


void
numcat(int fd)
{
   0:	7159                	addi	sp,sp,-112
   2:	f486                	sd	ra,104(sp)
   4:	f0a2                	sd	s0,96(sp)
   6:	eca6                	sd	s1,88(sp)
   8:	e8ca                	sd	s2,80(sp)
   a:	e4ce                	sd	s3,72(sp)
   c:	e0d2                	sd	s4,64(sp)
   e:	fc56                	sd	s5,56(sp)
  10:	f85a                	sd	s6,48(sp)
  12:	f45e                	sd	s7,40(sp)
  14:	f062                	sd	s8,32(sp)
  16:	ec66                	sd	s9,24(sp)
  18:	e86a                	sd	s10,16(sp)
  1a:	e46e                	sd	s11,8(sp)
  1c:	1880                	addi	s0,sp,112
  1e:	8caa                	mv	s9,a0
  int n;
  int cont=1;
  20:	4b05                	li	s6,1
  while((n = read(fd, buf, sizeof(buf))) > 0) {
  22:	00001d17          	auipc	s10,0x1
  26:	feed0d13          	addi	s10,s10,-18 # 1010 <buf>
    printf("%d",cont);
  2a:	00001c17          	auipc	s8,0x1
  2e:	996c0c13          	addi	s8,s8,-1642 # 9c0 <malloc+0xee>
    for (int i=0;i<n;i++)
  32:	4d81                	li	s11,0
    { printf("%c",buf[i]);
  34:	00001a97          	auipc	s5,0x1
  38:	994a8a93          	addi	s5,s5,-1644 # 9c8 <malloc+0xf6>
      if(buf[i]=='\n')
  3c:	4a29                	li	s4,10
  while((n = read(fd, buf, sizeof(buf))) > 0) {
  3e:	20000613          	li	a2,512
  42:	85ea                	mv	a1,s10
  44:	8566                	mv	a0,s9
  46:	00000097          	auipc	ra,0x0
  4a:	46a080e7          	jalr	1130(ra) # 4b0 <read>
  4e:	89aa                	mv	s3,a0
  50:	04a05963          	blez	a0,a2 <numcat+0xa2>
    printf("%d",cont);
  54:	85da                	mv	a1,s6
  56:	8562                	mv	a0,s8
  58:	00000097          	auipc	ra,0x0
  5c:	7c2080e7          	jalr	1986(ra) # 81a <printf>
    for (int i=0;i<n;i++)
  60:	00001497          	auipc	s1,0x1
  64:	fb048493          	addi	s1,s1,-80 # 1010 <buf>
  68:	896e                	mv	s2,s11
      {
        cont=cont+1;
        if(i<n-1)
  6a:	fff98b9b          	addiw	s7,s3,-1
  6e:	a029                	j	78 <numcat+0x78>
    for (int i=0;i<n;i++)
  70:	2905                	addiw	s2,s2,1
  72:	0485                	addi	s1,s1,1
  74:	fd2985e3          	beq	s3,s2,3e <numcat+0x3e>
    { printf("%c",buf[i]);
  78:	0004c583          	lbu	a1,0(s1)
  7c:	8556                	mv	a0,s5
  7e:	00000097          	auipc	ra,0x0
  82:	79c080e7          	jalr	1948(ra) # 81a <printf>
      if(buf[i]=='\n')
  86:	0004c783          	lbu	a5,0(s1)
  8a:	ff4793e3          	bne	a5,s4,70 <numcat+0x70>
        cont=cont+1;
  8e:	2b05                	addiw	s6,s6,1
        if(i<n-1)
  90:	ff7950e3          	bge	s2,s7,70 <numcat+0x70>
        {
        printf("%d",cont);
  94:	85da                	mv	a1,s6
  96:	8562                	mv	a0,s8
  98:	00000097          	auipc	ra,0x0
  9c:	782080e7          	jalr	1922(ra) # 81a <printf>
  a0:	bfc1                	j	70 <numcat+0x70>
        }
      }
    }
}
}
  a2:	70a6                	ld	ra,104(sp)
  a4:	7406                	ld	s0,96(sp)
  a6:	64e6                	ld	s1,88(sp)
  a8:	6946                	ld	s2,80(sp)
  aa:	69a6                	ld	s3,72(sp)
  ac:	6a06                	ld	s4,64(sp)
  ae:	7ae2                	ld	s5,56(sp)
  b0:	7b42                	ld	s6,48(sp)
  b2:	7ba2                	ld	s7,40(sp)
  b4:	7c02                	ld	s8,32(sp)
  b6:	6ce2                	ld	s9,24(sp)
  b8:	6d42                	ld	s10,16(sp)
  ba:	6da2                	ld	s11,8(sp)
  bc:	6165                	addi	sp,sp,112
  be:	8082                	ret

00000000000000c0 <cat>:

void
cat(int fd)
{
  c0:	7179                	addi	sp,sp,-48
  c2:	f406                	sd	ra,40(sp)
  c4:	f022                	sd	s0,32(sp)
  c6:	ec26                	sd	s1,24(sp)
  c8:	e84a                	sd	s2,16(sp)
  ca:	e44e                	sd	s3,8(sp)
  cc:	1800                	addi	s0,sp,48
  ce:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  d0:	00001917          	auipc	s2,0x1
  d4:	f4090913          	addi	s2,s2,-192 # 1010 <buf>
  d8:	20000613          	li	a2,512
  dc:	85ca                	mv	a1,s2
  de:	854e                	mv	a0,s3
  e0:	00000097          	auipc	ra,0x0
  e4:	3d0080e7          	jalr	976(ra) # 4b0 <read>
  e8:	84aa                	mv	s1,a0
  ea:	02a05963          	blez	a0,11c <cat+0x5c>
    
    if (write(1, buf, n) != n) {
  ee:	8626                	mv	a2,s1
  f0:	85ca                	mv	a1,s2
  f2:	4505                	li	a0,1
  f4:	00000097          	auipc	ra,0x0
  f8:	3c4080e7          	jalr	964(ra) # 4b8 <write>
  fc:	fc950ee3          	beq	a0,s1,d8 <cat+0x18>
      fprintf(2, "cat: write error\n");
 100:	00001597          	auipc	a1,0x1
 104:	8d058593          	addi	a1,a1,-1840 # 9d0 <malloc+0xfe>
 108:	4509                	li	a0,2
 10a:	00000097          	auipc	ra,0x0
 10e:	6e2080e7          	jalr	1762(ra) # 7ec <fprintf>
      exit(1);
 112:	4505                	li	a0,1
 114:	00000097          	auipc	ra,0x0
 118:	384080e7          	jalr	900(ra) # 498 <exit>
    }
  }
  if(n < 0){
 11c:	00054963          	bltz	a0,12e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
 120:	70a2                	ld	ra,40(sp)
 122:	7402                	ld	s0,32(sp)
 124:	64e2                	ld	s1,24(sp)
 126:	6942                	ld	s2,16(sp)
 128:	69a2                	ld	s3,8(sp)
 12a:	6145                	addi	sp,sp,48
 12c:	8082                	ret
    fprintf(2, "cat: read error\n");
 12e:	00001597          	auipc	a1,0x1
 132:	8ba58593          	addi	a1,a1,-1862 # 9e8 <malloc+0x116>
 136:	4509                	li	a0,2
 138:	00000097          	auipc	ra,0x0
 13c:	6b4080e7          	jalr	1716(ra) # 7ec <fprintf>
    exit(1);
 140:	4505                	li	a0,1
 142:	00000097          	auipc	ra,0x0
 146:	356080e7          	jalr	854(ra) # 498 <exit>

000000000000014a <main>:

int
main(int argc, char *argv[])
{
 14a:	715d                	addi	sp,sp,-80
 14c:	e486                	sd	ra,72(sp)
 14e:	e0a2                	sd	s0,64(sp)
 150:	fc26                	sd	s1,56(sp)
 152:	f84a                	sd	s2,48(sp)
 154:	f44e                	sd	s3,40(sp)
 156:	f052                	sd	s4,32(sp)
 158:	ec56                	sd	s5,24(sp)
 15a:	e85a                	sd	s6,16(sp)
 15c:	e45e                	sd	s7,8(sp)
 15e:	0880                	addi	s0,sp,80
  int count=1;
  int fd, i;

  if(argc <= 1){
 160:	4785                	li	a5,1
 162:	02a7d463          	bge	a5,a0,18a <main+0x40>
 166:	8a2a                	mv	s4,a0
 168:	892e                	mv	s2,a1
    cat(0);
    exit(0);
  }
  if(strcmp(argv[1],"-n")==0){
 16a:	00001597          	auipc	a1,0x1
 16e:	89658593          	addi	a1,a1,-1898 # a00 <malloc+0x12e>
 172:	00893503          	ld	a0,8(s2)
 176:	00000097          	auipc	ra,0x0
 17a:	0d2080e7          	jalr	210(ra) # 248 <strcmp>
 17e:	e105                	bnez	a0,19e <main+0x54>
    count=count+1;
  }

  for(i = count; i < argc; i++){
 180:	4789                	li	a5,2
 182:	0947d363          	bge	a5,s4,208 <main+0xbe>
    count=count+1;
 186:	4a89                	li	s5,2
 188:	a821                	j	1a0 <main+0x56>
    cat(0);
 18a:	4501                	li	a0,0
 18c:	00000097          	auipc	ra,0x0
 190:	f34080e7          	jalr	-204(ra) # c0 <cat>
    exit(0);
 194:	4501                	li	a0,0
 196:	00000097          	auipc	ra,0x0
 19a:	302080e7          	jalr	770(ra) # 498 <exit>
  int count=1;
 19e:	4a85                	li	s5,1
 1a0:	003a9793          	slli	a5,s5,0x3
 1a4:	993e                	add	s2,s2,a5
    count=count+1;
 1a6:	89d6                	mv	s3,s5
    if((fd = open(argv[i], 0)) < 0){
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    if(count==2)
 1a8:	4b89                	li	s7,2
 1aa:	a835                	j	1e6 <main+0x9c>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
 1ac:	00093603          	ld	a2,0(s2)
 1b0:	00001597          	auipc	a1,0x1
 1b4:	85858593          	addi	a1,a1,-1960 # a08 <malloc+0x136>
 1b8:	4509                	li	a0,2
 1ba:	00000097          	auipc	ra,0x0
 1be:	632080e7          	jalr	1586(ra) # 7ec <fprintf>
      exit(1);
 1c2:	4505                	li	a0,1
 1c4:	00000097          	auipc	ra,0x0
 1c8:	2d4080e7          	jalr	724(ra) # 498 <exit>
    {
      numcat(fd);
 1cc:	00000097          	auipc	ra,0x0
 1d0:	e34080e7          	jalr	-460(ra) # 0 <numcat>
    }
    else
    {
      cat(fd);
    }
    close(fd);
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	2ea080e7          	jalr	746(ra) # 4c0 <close>
  for(i = count; i < argc; i++){
 1de:	2985                	addiw	s3,s3,1
 1e0:	0921                	addi	s2,s2,8
 1e2:	0349d363          	bge	s3,s4,208 <main+0xbe>
    if((fd = open(argv[i], 0)) < 0){
 1e6:	4581                	li	a1,0
 1e8:	00093503          	ld	a0,0(s2)
 1ec:	00000097          	auipc	ra,0x0
 1f0:	2ec080e7          	jalr	748(ra) # 4d8 <open>
 1f4:	84aa                	mv	s1,a0
 1f6:	fa054be3          	bltz	a0,1ac <main+0x62>
    if(count==2)
 1fa:	fd7a89e3          	beq	s5,s7,1cc <main+0x82>
      cat(fd);
 1fe:	00000097          	auipc	ra,0x0
 202:	ec2080e7          	jalr	-318(ra) # c0 <cat>
 206:	b7f9                	j	1d4 <main+0x8a>
  }
  exit(0);
 208:	4501                	li	a0,0
 20a:	00000097          	auipc	ra,0x0
 20e:	28e080e7          	jalr	654(ra) # 498 <exit>

0000000000000212 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 212:	1141                	addi	sp,sp,-16
 214:	e406                	sd	ra,8(sp)
 216:	e022                	sd	s0,0(sp)
 218:	0800                	addi	s0,sp,16
  extern int main();
  main();
 21a:	00000097          	auipc	ra,0x0
 21e:	f30080e7          	jalr	-208(ra) # 14a <main>
  exit(0);
 222:	4501                	li	a0,0
 224:	00000097          	auipc	ra,0x0
 228:	274080e7          	jalr	628(ra) # 498 <exit>

000000000000022c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 232:	87aa                	mv	a5,a0
 234:	0585                	addi	a1,a1,1
 236:	0785                	addi	a5,a5,1
 238:	fff5c703          	lbu	a4,-1(a1)
 23c:	fee78fa3          	sb	a4,-1(a5)
 240:	fb75                	bnez	a4,234 <strcpy+0x8>
    ;
  return os;
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret

0000000000000248 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 24e:	00054783          	lbu	a5,0(a0)
 252:	cb91                	beqz	a5,266 <strcmp+0x1e>
 254:	0005c703          	lbu	a4,0(a1)
 258:	00f71763          	bne	a4,a5,266 <strcmp+0x1e>
    p++, q++;
 25c:	0505                	addi	a0,a0,1
 25e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 260:	00054783          	lbu	a5,0(a0)
 264:	fbe5                	bnez	a5,254 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 266:	0005c503          	lbu	a0,0(a1)
}
 26a:	40a7853b          	subw	a0,a5,a0
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret

0000000000000274 <strlen>:

uint
strlen(const char *s)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 27a:	00054783          	lbu	a5,0(a0)
 27e:	cf91                	beqz	a5,29a <strlen+0x26>
 280:	0505                	addi	a0,a0,1
 282:	87aa                	mv	a5,a0
 284:	4685                	li	a3,1
 286:	9e89                	subw	a3,a3,a0
 288:	00f6853b          	addw	a0,a3,a5
 28c:	0785                	addi	a5,a5,1
 28e:	fff7c703          	lbu	a4,-1(a5)
 292:	fb7d                	bnez	a4,288 <strlen+0x14>
    ;
  return n;
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
  for(n = 0; s[n]; n++)
 29a:	4501                	li	a0,0
 29c:	bfe5                	j	294 <strlen+0x20>

000000000000029e <memset>:

void*
memset(void *dst, int c, uint n)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2a4:	ca19                	beqz	a2,2ba <memset+0x1c>
 2a6:	87aa                	mv	a5,a0
 2a8:	1602                	slli	a2,a2,0x20
 2aa:	9201                	srli	a2,a2,0x20
 2ac:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2b0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2b4:	0785                	addi	a5,a5,1
 2b6:	fee79de3          	bne	a5,a4,2b0 <memset+0x12>
  }
  return dst;
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <strchr>:

char*
strchr(const char *s, char c)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	cb99                	beqz	a5,2e0 <strchr+0x20>
    if(*s == c)
 2cc:	00f58763          	beq	a1,a5,2da <strchr+0x1a>
  for(; *s; s++)
 2d0:	0505                	addi	a0,a0,1
 2d2:	00054783          	lbu	a5,0(a0)
 2d6:	fbfd                	bnez	a5,2cc <strchr+0xc>
      return (char*)s;
  return 0;
 2d8:	4501                	li	a0,0
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret
  return 0;
 2e0:	4501                	li	a0,0
 2e2:	bfe5                	j	2da <strchr+0x1a>

00000000000002e4 <gets>:

char*
gets(char *buf, int max)
{
 2e4:	711d                	addi	sp,sp,-96
 2e6:	ec86                	sd	ra,88(sp)
 2e8:	e8a2                	sd	s0,80(sp)
 2ea:	e4a6                	sd	s1,72(sp)
 2ec:	e0ca                	sd	s2,64(sp)
 2ee:	fc4e                	sd	s3,56(sp)
 2f0:	f852                	sd	s4,48(sp)
 2f2:	f456                	sd	s5,40(sp)
 2f4:	f05a                	sd	s6,32(sp)
 2f6:	ec5e                	sd	s7,24(sp)
 2f8:	1080                	addi	s0,sp,96
 2fa:	8baa                	mv	s7,a0
 2fc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2fe:	892a                	mv	s2,a0
 300:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 302:	4aa9                	li	s5,10
 304:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 306:	89a6                	mv	s3,s1
 308:	2485                	addiw	s1,s1,1
 30a:	0344d863          	bge	s1,s4,33a <gets+0x56>
    cc = read(0, &c, 1);
 30e:	4605                	li	a2,1
 310:	faf40593          	addi	a1,s0,-81
 314:	4501                	li	a0,0
 316:	00000097          	auipc	ra,0x0
 31a:	19a080e7          	jalr	410(ra) # 4b0 <read>
    if(cc < 1)
 31e:	00a05e63          	blez	a0,33a <gets+0x56>
    buf[i++] = c;
 322:	faf44783          	lbu	a5,-81(s0)
 326:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 32a:	01578763          	beq	a5,s5,338 <gets+0x54>
 32e:	0905                	addi	s2,s2,1
 330:	fd679be3          	bne	a5,s6,306 <gets+0x22>
  for(i=0; i+1 < max; ){
 334:	89a6                	mv	s3,s1
 336:	a011                	j	33a <gets+0x56>
 338:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 33a:	99de                	add	s3,s3,s7
 33c:	00098023          	sb	zero,0(s3)
  return buf;
}
 340:	855e                	mv	a0,s7
 342:	60e6                	ld	ra,88(sp)
 344:	6446                	ld	s0,80(sp)
 346:	64a6                	ld	s1,72(sp)
 348:	6906                	ld	s2,64(sp)
 34a:	79e2                	ld	s3,56(sp)
 34c:	7a42                	ld	s4,48(sp)
 34e:	7aa2                	ld	s5,40(sp)
 350:	7b02                	ld	s6,32(sp)
 352:	6be2                	ld	s7,24(sp)
 354:	6125                	addi	sp,sp,96
 356:	8082                	ret

0000000000000358 <stat>:

int
stat(const char *n, struct stat *st)
{
 358:	1101                	addi	sp,sp,-32
 35a:	ec06                	sd	ra,24(sp)
 35c:	e822                	sd	s0,16(sp)
 35e:	e426                	sd	s1,8(sp)
 360:	e04a                	sd	s2,0(sp)
 362:	1000                	addi	s0,sp,32
 364:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 366:	4581                	li	a1,0
 368:	00000097          	auipc	ra,0x0
 36c:	170080e7          	jalr	368(ra) # 4d8 <open>
  if(fd < 0)
 370:	02054563          	bltz	a0,39a <stat+0x42>
 374:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 376:	85ca                	mv	a1,s2
 378:	00000097          	auipc	ra,0x0
 37c:	178080e7          	jalr	376(ra) # 4f0 <fstat>
 380:	892a                	mv	s2,a0
  close(fd);
 382:	8526                	mv	a0,s1
 384:	00000097          	auipc	ra,0x0
 388:	13c080e7          	jalr	316(ra) # 4c0 <close>
  return r;
}
 38c:	854a                	mv	a0,s2
 38e:	60e2                	ld	ra,24(sp)
 390:	6442                	ld	s0,16(sp)
 392:	64a2                	ld	s1,8(sp)
 394:	6902                	ld	s2,0(sp)
 396:	6105                	addi	sp,sp,32
 398:	8082                	ret
    return -1;
 39a:	597d                	li	s2,-1
 39c:	bfc5                	j	38c <stat+0x34>

000000000000039e <atoi>:

int
atoi(const char *s)
{
 39e:	1141                	addi	sp,sp,-16
 3a0:	e422                	sd	s0,8(sp)
 3a2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3a4:	00054683          	lbu	a3,0(a0)
 3a8:	fd06879b          	addiw	a5,a3,-48
 3ac:	0ff7f793          	zext.b	a5,a5
 3b0:	4625                	li	a2,9
 3b2:	02f66863          	bltu	a2,a5,3e2 <atoi+0x44>
 3b6:	872a                	mv	a4,a0
  n = 0;
 3b8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3ba:	0705                	addi	a4,a4,1
 3bc:	0025179b          	slliw	a5,a0,0x2
 3c0:	9fa9                	addw	a5,a5,a0
 3c2:	0017979b          	slliw	a5,a5,0x1
 3c6:	9fb5                	addw	a5,a5,a3
 3c8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3cc:	00074683          	lbu	a3,0(a4)
 3d0:	fd06879b          	addiw	a5,a3,-48
 3d4:	0ff7f793          	zext.b	a5,a5
 3d8:	fef671e3          	bgeu	a2,a5,3ba <atoi+0x1c>
  return n;
}
 3dc:	6422                	ld	s0,8(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret
  n = 0;
 3e2:	4501                	li	a0,0
 3e4:	bfe5                	j	3dc <atoi+0x3e>

00000000000003e6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3e6:	1141                	addi	sp,sp,-16
 3e8:	e422                	sd	s0,8(sp)
 3ea:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ec:	02b57463          	bgeu	a0,a1,414 <memmove+0x2e>
    while(n-- > 0)
 3f0:	00c05f63          	blez	a2,40e <memmove+0x28>
 3f4:	1602                	slli	a2,a2,0x20
 3f6:	9201                	srli	a2,a2,0x20
 3f8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3fc:	872a                	mv	a4,a0
      *dst++ = *src++;
 3fe:	0585                	addi	a1,a1,1
 400:	0705                	addi	a4,a4,1
 402:	fff5c683          	lbu	a3,-1(a1)
 406:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 40a:	fee79ae3          	bne	a5,a4,3fe <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 40e:	6422                	ld	s0,8(sp)
 410:	0141                	addi	sp,sp,16
 412:	8082                	ret
    dst += n;
 414:	00c50733          	add	a4,a0,a2
    src += n;
 418:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 41a:	fec05ae3          	blez	a2,40e <memmove+0x28>
 41e:	fff6079b          	addiw	a5,a2,-1
 422:	1782                	slli	a5,a5,0x20
 424:	9381                	srli	a5,a5,0x20
 426:	fff7c793          	not	a5,a5
 42a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 42c:	15fd                	addi	a1,a1,-1
 42e:	177d                	addi	a4,a4,-1
 430:	0005c683          	lbu	a3,0(a1)
 434:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 438:	fee79ae3          	bne	a5,a4,42c <memmove+0x46>
 43c:	bfc9                	j	40e <memmove+0x28>

000000000000043e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 43e:	1141                	addi	sp,sp,-16
 440:	e422                	sd	s0,8(sp)
 442:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 444:	ca05                	beqz	a2,474 <memcmp+0x36>
 446:	fff6069b          	addiw	a3,a2,-1
 44a:	1682                	slli	a3,a3,0x20
 44c:	9281                	srli	a3,a3,0x20
 44e:	0685                	addi	a3,a3,1
 450:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 452:	00054783          	lbu	a5,0(a0)
 456:	0005c703          	lbu	a4,0(a1)
 45a:	00e79863          	bne	a5,a4,46a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 45e:	0505                	addi	a0,a0,1
    p2++;
 460:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 462:	fed518e3          	bne	a0,a3,452 <memcmp+0x14>
  }
  return 0;
 466:	4501                	li	a0,0
 468:	a019                	j	46e <memcmp+0x30>
      return *p1 - *p2;
 46a:	40e7853b          	subw	a0,a5,a4
}
 46e:	6422                	ld	s0,8(sp)
 470:	0141                	addi	sp,sp,16
 472:	8082                	ret
  return 0;
 474:	4501                	li	a0,0
 476:	bfe5                	j	46e <memcmp+0x30>

0000000000000478 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 478:	1141                	addi	sp,sp,-16
 47a:	e406                	sd	ra,8(sp)
 47c:	e022                	sd	s0,0(sp)
 47e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 480:	00000097          	auipc	ra,0x0
 484:	f66080e7          	jalr	-154(ra) # 3e6 <memmove>
}
 488:	60a2                	ld	ra,8(sp)
 48a:	6402                	ld	s0,0(sp)
 48c:	0141                	addi	sp,sp,16
 48e:	8082                	ret

0000000000000490 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 490:	4885                	li	a7,1
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <exit>:
.global exit
exit:
 li a7, SYS_exit
 498:	4889                	li	a7,2
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4a0:	488d                	li	a7,3
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4a8:	4891                	li	a7,4
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <read>:
.global read
read:
 li a7, SYS_read
 4b0:	4895                	li	a7,5
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <write>:
.global write
write:
 li a7, SYS_write
 4b8:	48c1                	li	a7,16
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <close>:
.global close
close:
 li a7, SYS_close
 4c0:	48d5                	li	a7,21
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4c8:	4899                	li	a7,6
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4d0:	489d                	li	a7,7
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <open>:
.global open
open:
 li a7, SYS_open
 4d8:	48bd                	li	a7,15
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4e0:	48c5                	li	a7,17
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4e8:	48c9                	li	a7,18
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4f0:	48a1                	li	a7,8
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <link>:
.global link
link:
 li a7, SYS_link
 4f8:	48cd                	li	a7,19
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 500:	48d1                	li	a7,20
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 508:	48a5                	li	a7,9
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <dup>:
.global dup
dup:
 li a7, SYS_dup
 510:	48a9                	li	a7,10
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 518:	48ad                	li	a7,11
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 520:	48b1                	li	a7,12
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 528:	48b5                	li	a7,13
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 530:	48b9                	li	a7,14
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <cow>:
.global cow
cow:
 li a7, SYS_cow
 538:	48d9                	li	a7,22
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 540:	1101                	addi	sp,sp,-32
 542:	ec06                	sd	ra,24(sp)
 544:	e822                	sd	s0,16(sp)
 546:	1000                	addi	s0,sp,32
 548:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 54c:	4605                	li	a2,1
 54e:	fef40593          	addi	a1,s0,-17
 552:	00000097          	auipc	ra,0x0
 556:	f66080e7          	jalr	-154(ra) # 4b8 <write>
}
 55a:	60e2                	ld	ra,24(sp)
 55c:	6442                	ld	s0,16(sp)
 55e:	6105                	addi	sp,sp,32
 560:	8082                	ret

0000000000000562 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 562:	7139                	addi	sp,sp,-64
 564:	fc06                	sd	ra,56(sp)
 566:	f822                	sd	s0,48(sp)
 568:	f426                	sd	s1,40(sp)
 56a:	f04a                	sd	s2,32(sp)
 56c:	ec4e                	sd	s3,24(sp)
 56e:	0080                	addi	s0,sp,64
 570:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 572:	c299                	beqz	a3,578 <printint+0x16>
 574:	0805c963          	bltz	a1,606 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 578:	2581                	sext.w	a1,a1
  neg = 0;
 57a:	4881                	li	a7,0
 57c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 580:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 582:	2601                	sext.w	a2,a2
 584:	00000517          	auipc	a0,0x0
 588:	4fc50513          	addi	a0,a0,1276 # a80 <digits>
 58c:	883a                	mv	a6,a4
 58e:	2705                	addiw	a4,a4,1
 590:	02c5f7bb          	remuw	a5,a1,a2
 594:	1782                	slli	a5,a5,0x20
 596:	9381                	srli	a5,a5,0x20
 598:	97aa                	add	a5,a5,a0
 59a:	0007c783          	lbu	a5,0(a5)
 59e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5a2:	0005879b          	sext.w	a5,a1
 5a6:	02c5d5bb          	divuw	a1,a1,a2
 5aa:	0685                	addi	a3,a3,1
 5ac:	fec7f0e3          	bgeu	a5,a2,58c <printint+0x2a>
  if(neg)
 5b0:	00088c63          	beqz	a7,5c8 <printint+0x66>
    buf[i++] = '-';
 5b4:	fd070793          	addi	a5,a4,-48
 5b8:	00878733          	add	a4,a5,s0
 5bc:	02d00793          	li	a5,45
 5c0:	fef70823          	sb	a5,-16(a4)
 5c4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5c8:	02e05863          	blez	a4,5f8 <printint+0x96>
 5cc:	fc040793          	addi	a5,s0,-64
 5d0:	00e78933          	add	s2,a5,a4
 5d4:	fff78993          	addi	s3,a5,-1
 5d8:	99ba                	add	s3,s3,a4
 5da:	377d                	addiw	a4,a4,-1
 5dc:	1702                	slli	a4,a4,0x20
 5de:	9301                	srli	a4,a4,0x20
 5e0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5e4:	fff94583          	lbu	a1,-1(s2)
 5e8:	8526                	mv	a0,s1
 5ea:	00000097          	auipc	ra,0x0
 5ee:	f56080e7          	jalr	-170(ra) # 540 <putc>
  while(--i >= 0)
 5f2:	197d                	addi	s2,s2,-1
 5f4:	ff3918e3          	bne	s2,s3,5e4 <printint+0x82>
}
 5f8:	70e2                	ld	ra,56(sp)
 5fa:	7442                	ld	s0,48(sp)
 5fc:	74a2                	ld	s1,40(sp)
 5fe:	7902                	ld	s2,32(sp)
 600:	69e2                	ld	s3,24(sp)
 602:	6121                	addi	sp,sp,64
 604:	8082                	ret
    x = -xx;
 606:	40b005bb          	negw	a1,a1
    neg = 1;
 60a:	4885                	li	a7,1
    x = -xx;
 60c:	bf85                	j	57c <printint+0x1a>

000000000000060e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 60e:	7119                	addi	sp,sp,-128
 610:	fc86                	sd	ra,120(sp)
 612:	f8a2                	sd	s0,112(sp)
 614:	f4a6                	sd	s1,104(sp)
 616:	f0ca                	sd	s2,96(sp)
 618:	ecce                	sd	s3,88(sp)
 61a:	e8d2                	sd	s4,80(sp)
 61c:	e4d6                	sd	s5,72(sp)
 61e:	e0da                	sd	s6,64(sp)
 620:	fc5e                	sd	s7,56(sp)
 622:	f862                	sd	s8,48(sp)
 624:	f466                	sd	s9,40(sp)
 626:	f06a                	sd	s10,32(sp)
 628:	ec6e                	sd	s11,24(sp)
 62a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 62c:	0005c903          	lbu	s2,0(a1)
 630:	18090f63          	beqz	s2,7ce <vprintf+0x1c0>
 634:	8aaa                	mv	s5,a0
 636:	8b32                	mv	s6,a2
 638:	00158493          	addi	s1,a1,1
  state = 0;
 63c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 63e:	02500a13          	li	s4,37
 642:	4c55                	li	s8,21
 644:	00000c97          	auipc	s9,0x0
 648:	3e4c8c93          	addi	s9,s9,996 # a28 <malloc+0x156>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 64c:	02800d93          	li	s11,40
  putc(fd, 'x');
 650:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 652:	00000b97          	auipc	s7,0x0
 656:	42eb8b93          	addi	s7,s7,1070 # a80 <digits>
 65a:	a839                	j	678 <vprintf+0x6a>
        putc(fd, c);
 65c:	85ca                	mv	a1,s2
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	ee0080e7          	jalr	-288(ra) # 540 <putc>
 668:	a019                	j	66e <vprintf+0x60>
    } else if(state == '%'){
 66a:	01498d63          	beq	s3,s4,684 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 66e:	0485                	addi	s1,s1,1
 670:	fff4c903          	lbu	s2,-1(s1)
 674:	14090d63          	beqz	s2,7ce <vprintf+0x1c0>
    if(state == 0){
 678:	fe0999e3          	bnez	s3,66a <vprintf+0x5c>
      if(c == '%'){
 67c:	ff4910e3          	bne	s2,s4,65c <vprintf+0x4e>
        state = '%';
 680:	89d2                	mv	s3,s4
 682:	b7f5                	j	66e <vprintf+0x60>
      if(c == 'd'){
 684:	11490c63          	beq	s2,s4,79c <vprintf+0x18e>
 688:	f9d9079b          	addiw	a5,s2,-99
 68c:	0ff7f793          	zext.b	a5,a5
 690:	10fc6e63          	bltu	s8,a5,7ac <vprintf+0x19e>
 694:	f9d9079b          	addiw	a5,s2,-99
 698:	0ff7f713          	zext.b	a4,a5
 69c:	10ec6863          	bltu	s8,a4,7ac <vprintf+0x19e>
 6a0:	00271793          	slli	a5,a4,0x2
 6a4:	97e6                	add	a5,a5,s9
 6a6:	439c                	lw	a5,0(a5)
 6a8:	97e6                	add	a5,a5,s9
 6aa:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6ac:	008b0913          	addi	s2,s6,8
 6b0:	4685                	li	a3,1
 6b2:	4629                	li	a2,10
 6b4:	000b2583          	lw	a1,0(s6)
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	ea8080e7          	jalr	-344(ra) # 562 <printint>
 6c2:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b765                	j	66e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c8:	008b0913          	addi	s2,s6,8
 6cc:	4681                	li	a3,0
 6ce:	4629                	li	a2,10
 6d0:	000b2583          	lw	a1,0(s6)
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	e8c080e7          	jalr	-372(ra) # 562 <printint>
 6de:	8b4a                	mv	s6,s2
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	b771                	j	66e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6e4:	008b0913          	addi	s2,s6,8
 6e8:	4681                	li	a3,0
 6ea:	866a                	mv	a2,s10
 6ec:	000b2583          	lw	a1,0(s6)
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e70080e7          	jalr	-400(ra) # 562 <printint>
 6fa:	8b4a                	mv	s6,s2
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	bf85                	j	66e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 700:	008b0793          	addi	a5,s6,8
 704:	f8f43423          	sd	a5,-120(s0)
 708:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 70c:	03000593          	li	a1,48
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	e2e080e7          	jalr	-466(ra) # 540 <putc>
  putc(fd, 'x');
 71a:	07800593          	li	a1,120
 71e:	8556                	mv	a0,s5
 720:	00000097          	auipc	ra,0x0
 724:	e20080e7          	jalr	-480(ra) # 540 <putc>
 728:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 72a:	03c9d793          	srli	a5,s3,0x3c
 72e:	97de                	add	a5,a5,s7
 730:	0007c583          	lbu	a1,0(a5)
 734:	8556                	mv	a0,s5
 736:	00000097          	auipc	ra,0x0
 73a:	e0a080e7          	jalr	-502(ra) # 540 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 73e:	0992                	slli	s3,s3,0x4
 740:	397d                	addiw	s2,s2,-1
 742:	fe0914e3          	bnez	s2,72a <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 746:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 74a:	4981                	li	s3,0
 74c:	b70d                	j	66e <vprintf+0x60>
        s = va_arg(ap, char*);
 74e:	008b0913          	addi	s2,s6,8
 752:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 756:	02098163          	beqz	s3,778 <vprintf+0x16a>
        while(*s != 0){
 75a:	0009c583          	lbu	a1,0(s3)
 75e:	c5ad                	beqz	a1,7c8 <vprintf+0x1ba>
          putc(fd, *s);
 760:	8556                	mv	a0,s5
 762:	00000097          	auipc	ra,0x0
 766:	dde080e7          	jalr	-546(ra) # 540 <putc>
          s++;
 76a:	0985                	addi	s3,s3,1
        while(*s != 0){
 76c:	0009c583          	lbu	a1,0(s3)
 770:	f9e5                	bnez	a1,760 <vprintf+0x152>
        s = va_arg(ap, char*);
 772:	8b4a                	mv	s6,s2
      state = 0;
 774:	4981                	li	s3,0
 776:	bde5                	j	66e <vprintf+0x60>
          s = "(null)";
 778:	00000997          	auipc	s3,0x0
 77c:	2a898993          	addi	s3,s3,680 # a20 <malloc+0x14e>
        while(*s != 0){
 780:	85ee                	mv	a1,s11
 782:	bff9                	j	760 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 784:	008b0913          	addi	s2,s6,8
 788:	000b4583          	lbu	a1,0(s6)
 78c:	8556                	mv	a0,s5
 78e:	00000097          	auipc	ra,0x0
 792:	db2080e7          	jalr	-590(ra) # 540 <putc>
 796:	8b4a                	mv	s6,s2
      state = 0;
 798:	4981                	li	s3,0
 79a:	bdd1                	j	66e <vprintf+0x60>
        putc(fd, c);
 79c:	85d2                	mv	a1,s4
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	da0080e7          	jalr	-608(ra) # 540 <putc>
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	b5d1                	j	66e <vprintf+0x60>
        putc(fd, '%');
 7ac:	85d2                	mv	a1,s4
 7ae:	8556                	mv	a0,s5
 7b0:	00000097          	auipc	ra,0x0
 7b4:	d90080e7          	jalr	-624(ra) # 540 <putc>
        putc(fd, c);
 7b8:	85ca                	mv	a1,s2
 7ba:	8556                	mv	a0,s5
 7bc:	00000097          	auipc	ra,0x0
 7c0:	d84080e7          	jalr	-636(ra) # 540 <putc>
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	b565                	j	66e <vprintf+0x60>
        s = va_arg(ap, char*);
 7c8:	8b4a                	mv	s6,s2
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	b54d                	j	66e <vprintf+0x60>
    }
  }
}
 7ce:	70e6                	ld	ra,120(sp)
 7d0:	7446                	ld	s0,112(sp)
 7d2:	74a6                	ld	s1,104(sp)
 7d4:	7906                	ld	s2,96(sp)
 7d6:	69e6                	ld	s3,88(sp)
 7d8:	6a46                	ld	s4,80(sp)
 7da:	6aa6                	ld	s5,72(sp)
 7dc:	6b06                	ld	s6,64(sp)
 7de:	7be2                	ld	s7,56(sp)
 7e0:	7c42                	ld	s8,48(sp)
 7e2:	7ca2                	ld	s9,40(sp)
 7e4:	7d02                	ld	s10,32(sp)
 7e6:	6de2                	ld	s11,24(sp)
 7e8:	6109                	addi	sp,sp,128
 7ea:	8082                	ret

00000000000007ec <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ec:	715d                	addi	sp,sp,-80
 7ee:	ec06                	sd	ra,24(sp)
 7f0:	e822                	sd	s0,16(sp)
 7f2:	1000                	addi	s0,sp,32
 7f4:	e010                	sd	a2,0(s0)
 7f6:	e414                	sd	a3,8(s0)
 7f8:	e818                	sd	a4,16(s0)
 7fa:	ec1c                	sd	a5,24(s0)
 7fc:	03043023          	sd	a6,32(s0)
 800:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 804:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 808:	8622                	mv	a2,s0
 80a:	00000097          	auipc	ra,0x0
 80e:	e04080e7          	jalr	-508(ra) # 60e <vprintf>
}
 812:	60e2                	ld	ra,24(sp)
 814:	6442                	ld	s0,16(sp)
 816:	6161                	addi	sp,sp,80
 818:	8082                	ret

000000000000081a <printf>:

void
printf(const char *fmt, ...)
{
 81a:	711d                	addi	sp,sp,-96
 81c:	ec06                	sd	ra,24(sp)
 81e:	e822                	sd	s0,16(sp)
 820:	1000                	addi	s0,sp,32
 822:	e40c                	sd	a1,8(s0)
 824:	e810                	sd	a2,16(s0)
 826:	ec14                	sd	a3,24(s0)
 828:	f018                	sd	a4,32(s0)
 82a:	f41c                	sd	a5,40(s0)
 82c:	03043823          	sd	a6,48(s0)
 830:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 834:	00840613          	addi	a2,s0,8
 838:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 83c:	85aa                	mv	a1,a0
 83e:	4505                	li	a0,1
 840:	00000097          	auipc	ra,0x0
 844:	dce080e7          	jalr	-562(ra) # 60e <vprintf>
}
 848:	60e2                	ld	ra,24(sp)
 84a:	6442                	ld	s0,16(sp)
 84c:	6125                	addi	sp,sp,96
 84e:	8082                	ret

0000000000000850 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 850:	1141                	addi	sp,sp,-16
 852:	e422                	sd	s0,8(sp)
 854:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 856:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85a:	00000797          	auipc	a5,0x0
 85e:	7a67b783          	ld	a5,1958(a5) # 1000 <freep>
 862:	a02d                	j	88c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 864:	4618                	lw	a4,8(a2)
 866:	9f2d                	addw	a4,a4,a1
 868:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 86c:	6398                	ld	a4,0(a5)
 86e:	6310                	ld	a2,0(a4)
 870:	a83d                	j	8ae <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 872:	ff852703          	lw	a4,-8(a0)
 876:	9f31                	addw	a4,a4,a2
 878:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 87a:	ff053683          	ld	a3,-16(a0)
 87e:	a091                	j	8c2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 880:	6398                	ld	a4,0(a5)
 882:	00e7e463          	bltu	a5,a4,88a <free+0x3a>
 886:	00e6ea63          	bltu	a3,a4,89a <free+0x4a>
{
 88a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88c:	fed7fae3          	bgeu	a5,a3,880 <free+0x30>
 890:	6398                	ld	a4,0(a5)
 892:	00e6e463          	bltu	a3,a4,89a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 896:	fee7eae3          	bltu	a5,a4,88a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 89a:	ff852583          	lw	a1,-8(a0)
 89e:	6390                	ld	a2,0(a5)
 8a0:	02059813          	slli	a6,a1,0x20
 8a4:	01c85713          	srli	a4,a6,0x1c
 8a8:	9736                	add	a4,a4,a3
 8aa:	fae60de3          	beq	a2,a4,864 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8ae:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8b2:	4790                	lw	a2,8(a5)
 8b4:	02061593          	slli	a1,a2,0x20
 8b8:	01c5d713          	srli	a4,a1,0x1c
 8bc:	973e                	add	a4,a4,a5
 8be:	fae68ae3          	beq	a3,a4,872 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8c2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8c4:	00000717          	auipc	a4,0x0
 8c8:	72f73e23          	sd	a5,1852(a4) # 1000 <freep>
}
 8cc:	6422                	ld	s0,8(sp)
 8ce:	0141                	addi	sp,sp,16
 8d0:	8082                	ret

00000000000008d2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8d2:	7139                	addi	sp,sp,-64
 8d4:	fc06                	sd	ra,56(sp)
 8d6:	f822                	sd	s0,48(sp)
 8d8:	f426                	sd	s1,40(sp)
 8da:	f04a                	sd	s2,32(sp)
 8dc:	ec4e                	sd	s3,24(sp)
 8de:	e852                	sd	s4,16(sp)
 8e0:	e456                	sd	s5,8(sp)
 8e2:	e05a                	sd	s6,0(sp)
 8e4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e6:	02051493          	slli	s1,a0,0x20
 8ea:	9081                	srli	s1,s1,0x20
 8ec:	04bd                	addi	s1,s1,15
 8ee:	8091                	srli	s1,s1,0x4
 8f0:	0014899b          	addiw	s3,s1,1
 8f4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8f6:	00000517          	auipc	a0,0x0
 8fa:	70a53503          	ld	a0,1802(a0) # 1000 <freep>
 8fe:	c515                	beqz	a0,92a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 900:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 902:	4798                	lw	a4,8(a5)
 904:	02977f63          	bgeu	a4,s1,942 <malloc+0x70>
 908:	8a4e                	mv	s4,s3
 90a:	0009871b          	sext.w	a4,s3
 90e:	6685                	lui	a3,0x1
 910:	00d77363          	bgeu	a4,a3,916 <malloc+0x44>
 914:	6a05                	lui	s4,0x1
 916:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 91a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 91e:	00000917          	auipc	s2,0x0
 922:	6e290913          	addi	s2,s2,1762 # 1000 <freep>
  if(p == (char*)-1)
 926:	5afd                	li	s5,-1
 928:	a895                	j	99c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 92a:	00001797          	auipc	a5,0x1
 92e:	8e678793          	addi	a5,a5,-1818 # 1210 <base>
 932:	00000717          	auipc	a4,0x0
 936:	6cf73723          	sd	a5,1742(a4) # 1000 <freep>
 93a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 93c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 940:	b7e1                	j	908 <malloc+0x36>
      if(p->s.size == nunits)
 942:	02e48c63          	beq	s1,a4,97a <malloc+0xa8>
        p->s.size -= nunits;
 946:	4137073b          	subw	a4,a4,s3
 94a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 94c:	02071693          	slli	a3,a4,0x20
 950:	01c6d713          	srli	a4,a3,0x1c
 954:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 956:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 95a:	00000717          	auipc	a4,0x0
 95e:	6aa73323          	sd	a0,1702(a4) # 1000 <freep>
      return (void*)(p + 1);
 962:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 966:	70e2                	ld	ra,56(sp)
 968:	7442                	ld	s0,48(sp)
 96a:	74a2                	ld	s1,40(sp)
 96c:	7902                	ld	s2,32(sp)
 96e:	69e2                	ld	s3,24(sp)
 970:	6a42                	ld	s4,16(sp)
 972:	6aa2                	ld	s5,8(sp)
 974:	6b02                	ld	s6,0(sp)
 976:	6121                	addi	sp,sp,64
 978:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 97a:	6398                	ld	a4,0(a5)
 97c:	e118                	sd	a4,0(a0)
 97e:	bff1                	j	95a <malloc+0x88>
  hp->s.size = nu;
 980:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 984:	0541                	addi	a0,a0,16
 986:	00000097          	auipc	ra,0x0
 98a:	eca080e7          	jalr	-310(ra) # 850 <free>
  return freep;
 98e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 992:	d971                	beqz	a0,966 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 994:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 996:	4798                	lw	a4,8(a5)
 998:	fa9775e3          	bgeu	a4,s1,942 <malloc+0x70>
    if(p == freep)
 99c:	00093703          	ld	a4,0(s2)
 9a0:	853e                	mv	a0,a5
 9a2:	fef719e3          	bne	a4,a5,994 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9a6:	8552                	mv	a0,s4
 9a8:	00000097          	auipc	ra,0x0
 9ac:	b78080e7          	jalr	-1160(ra) # 520 <sbrk>
  if(p == (char*)-1)
 9b0:	fd5518e3          	bne	a0,s5,980 <malloc+0xae>
        return 0;
 9b4:	4501                	li	a0,0
 9b6:	bf45                	j	966 <malloc+0x94>
