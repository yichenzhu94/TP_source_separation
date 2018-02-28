#include "config.h"
#ifdef HAVE_COMPLEX_H
#include <complex.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "fftw3.h"
#include "ltfat.h"

/*  This routine computes the DGT factorization using strided FFTs so
    the memory layout is optimized for the matrix product. Compared to
    dgt_fac_1, it moves the r-loop to be the outermost loop to
    conserve memory and hopefully use the cache hierachy better 

    The routine uses a very small buffer to do the DFTs.

    Integer indexing is optimized.

    Special code for integer oversampling.

    Code works on LTFAT_REAL's instead on LTFAT_COMPLEX
*/


LTFAT_EXTERN void
LTFAT_NAME(dgt_walnut_plan)(LTFAT_NAME(dgt_long_plan) plan)
{

   /*  --------- initial declarations -------------- */

   LTFAT_REAL *gbase, *fbase, *cbase;

   int rem;

   LTFAT_REAL *ffp, *fp, *cfp;

   /*  ----------- calculation of parameters and plans -------- */
   
   const int a=plan.a;
   const int M=plan.M;
   const int L=plan.L;
   const int W=plan.W;
   const int N=L/a;
   const int c=plan.c;
   const int p=a/c;
   const int q=M/c;
   const int d=N/q;

   const LTFAT_COMPLEX *f = plan.f;
   const LTFAT_COMPLEX *gf = (const LTFAT_COMPLEX *)plan.gf;
   
   const int h_a=plan.h_a;

   LTFAT_REAL *sbuf=plan.sbuf;
   LTFAT_COMPLEX *cout=plan.cout;

   /* Scaling constant needed because of FFTWs normalization. */
   const LTFAT_REAL scalconst=1.0/((LTFAT_REAL)d*sqrt((LTFAT_REAL)M));

   /* Leading dimensions of the 4dim array. */
   const int ld2a=2*p*q*W;

   /* Leading dimensions of cf */
   const int ld3b=2*q*q*W;
   const int ld5c=M*N;

   /* --------- main loop begins here ------------------- */
   for (int r=0;r<c;r++)
   {
      
      
      /*  ---------- compute signal factorization ----------- */
      ffp=plan.ff;
      fp=(LTFAT_REAL*)f+2*r;
      if (p==1)
      {
	 /* Integer oversampling case */
	 
	 for (int w=0;w<W;w++)
	 {
	    for (int l=0;l<q;l++)
	    {
	       for (int s=0;s<d;s++)
	       {		  
		  rem = 2*((s*M+l*a)%L);
		  sbuf[2*s]   = fp[rem];
		  sbuf[2*s+1] = fp[rem+1];
	       }
	       
	       LTFAT_FFTW(execute)(plan.p_before);
	       
	       for (int s=0;s<d;s++)
	       {		  
		 ffp[s*ld2a]   = sbuf[2*s]*scalconst;
		 ffp[s*ld2a+1] = sbuf[2*s+1]*scalconst;
	       }
	       ffp+=2;
	    }
	    fp+=2*L;
	 }
	 fp-=2*L*W;
	 
	 /* Do the Matmul */	 
	 for (int s=0;s<d;s++)
	 {	
	    gbase=(LTFAT_REAL*)gf+2*(r+s*c)*q;
	    fbase=plan.ff+2*s*q*W;
	    cbase=plan.cf+2*s*q*q*W;
	    
	    for (int nm=0;nm<q*W;nm++)
	    {
	       for (int mm=0;mm<q;mm++)
	       {
		  cbase[0]=gbase[0]*fbase[0]+gbase[1]*fbase[1];
		  cbase[1]=gbase[0]*fbase[1]-gbase[1]*fbase[0];
		  gbase+=2;
		  cbase+=2;
	       }			       
	       gbase-=2*q;
	       fbase+=2;
	    }
	    cbase-=2*q*q*W;
	 }


      }
      else
      {      
	 /* rational sampling case */

	 for (int w=0;w<W;w++)
	 {
	    for (int l=0;l<q;l++)
	    {
	       for (int k=0;k<p;k++)
	       {
		  for (int s=0;s<d;s++)
		  {		  
		     rem = 2*positiverem(k*M+s*p*M-l*h_a*a, L);
		     sbuf[2*s]   = fp[rem];
		     sbuf[2*s+1] = fp[rem+1];
		  }
		  
		  LTFAT_FFTW(execute)(plan.p_before);
		  
		  for (int s=0;s<d;s++)
		  {		  
		     ffp[s*ld2a]   = sbuf[2*s]*scalconst;
		     ffp[s*ld2a+1] = sbuf[2*s+1]*scalconst;
		  }
		  ffp+=2;
	       }
	    }
	    fp+=2*L;
	 }
	 fp-=2*L*W;

	 for (int s=0;s<d;s++)
	 {	
	    gbase=(LTFAT_REAL*)gf+2*(r+s*c)*p*q;
	    fbase=plan.ff+2*s*p*q*W;
	    cbase=plan.cf+2*s*q*q*W;
	    
	    for (int nm=0;nm<q*W;nm++)
	    {
	       for (int mm=0;mm<q;mm++)
	       {
		  cbase[0]=0.0;
		  cbase[1]=0.0;
		  for (int km=0;km<p;km++)
		  {
		     cbase[0]+=gbase[0]*fbase[0]+gbase[1]*fbase[1];
		     cbase[1]+=gbase[0]*fbase[1]-gbase[1]*fbase[0];
		     gbase+=2;
		     fbase+=2;
		  }
		  fbase-=2*p;
		  cbase+=2;
	       }			       
	       gbase-=2*q*p;
	       fbase+=2*p;
	    }
	    cbase-=2*q*q*W;
	    fbase-=2*p*q*W;
	 }

      } /* end of if p==1 */

      /*  -------  compute inverse coefficient factorization ------- */
      cfp=plan.cf;

      /* Cover both integer and rational sampling case */
      for (int w=0;w<W;w++)
      {
	 /* Complete inverse fac of coefficients */
	 for (int l=0;l<q;l++)
	 {
	    for (int u=0;u<q;u++)
	    {	       	       
	       for (int s=0;s<d;s++)	       
	       {	
		  sbuf[2*s]   = cfp[s*ld3b];
		  sbuf[2*s+1] = cfp[s*ld3b+1];
	       }
	       cfp+=2;
	       
	       /* Do inverse fft of length d */
	       LTFAT_FFTW(execute)(plan.p_after);
	       
	       for (int s=0;s<d;s++)	       
	       {	
		  rem= r+l*c+positiverem(u+s*q-l*h_a,N)*M+w*ld5c;
		  cout[rem][0]=sbuf[2*s];
		  cout[rem][1]=sbuf[2*s+1];
	       }		    
	    }
	 }
      }            
      
      
      /* ----------- Main loop ends here ------------------------ */
   }     
   
}




/* -------------- Real valued signal ------------------------ */


LTFAT_EXTERN void
LTFAT_NAME(dgt_walnut_r)(const LTFAT_REAL *f, const LTFAT_COMPLEX *gf,
			      const int L,
			      const int W, const int a,
			      const int M, LTFAT_COMPLEX *cout)
{

   /*  --------- initial declarations -------------- */

   int b, N, c, d, p, q, h_a, h_m;
   
   LTFAT_REAL *gbase, *fbase, *cbase;

   int l, k, r, s, u, w, nm, mm, km;
   int ld2a, ld3b;
   int rem;

   LTFAT_FFTW(plan) p_before, p_after;
   LTFAT_REAL *ff, *cf, *ffp, *sbuf, *cfp;

   const LTFAT_REAL *fp;



   LTFAT_REAL scalconst;   

   /*  ----------- calculation of parameters and plans -------- */
   
   b=L/M;
   N=L/a;
   
   c=gcd(a, M,&h_a, &h_m);
   p=a/c;
   q=M/c;
   d=b/p;

   h_a=-h_a;

   /* Scaling constant needed because of FFTWs normalization. */
   scalconst=1.0/((LTFAT_REAL)d*sqrt((LTFAT_REAL)M));

   ff = (LTFAT_REAL*)ltfat_malloc(2*d*p*q*W*sizeof(LTFAT_REAL));
   cf = (LTFAT_REAL*)ltfat_malloc(2*d*q*q*W*sizeof(LTFAT_REAL));
   sbuf = (LTFAT_REAL*)ltfat_malloc(2*d*sizeof(LTFAT_REAL));

   /* Create plans. In-place. */

   p_before = LTFAT_FFTW(plan_dft_1d)(d, (LTFAT_COMPLEX*)sbuf, (LTFAT_COMPLEX*)sbuf,
			       FFTW_FORWARD, FFTW_ESTIMATE);

   p_after  = LTFAT_FFTW(plan_dft_1d)(d, (LTFAT_COMPLEX*)sbuf, (LTFAT_COMPLEX*)sbuf,
			       FFTW_BACKWARD, FFTW_ESTIMATE);
   
   /* Leading dimensions of the 4dim array. */
   ld2a=2*p*q*W;

   /* Leading dimensions of cf */
   ld3b=2*q*q*W;

   /* --------- main loop begins here ------------------- */
   for (r=0;r<c;r++)
   {            
      /*  ---------- compute signal factorization ----------- */
      ffp=ff;
      fp=f+r;
      if (p==1)	
      {
	 /* Integer oversampling case */	 
	 for (w=0;w<W;w++)
	 {
	    for (l=0;l<q;l++)
	    {
	       for (s=0;s<d;s++)
	       {		  
		  rem = (s*M+l*a)%L;
		  sbuf[2*s]   = fp[rem];
		  sbuf[2*s+1] = 0.0;
	       }
	       
	       LTFAT_FFTW(execute)(p_before);
	       
	       for (s=0;s<d;s++)
	       {		  
		 ffp[s*ld2a]   = sbuf[2*s]*scalconst;
		 ffp[s*ld2a+1] = sbuf[2*s+1]*scalconst;
	       }
	       ffp+=2;
	    }
	    fp+=L;
	 }
	 fp-=2*L*W;	 
      }
      else
      {      
	 /* rational sampling case */

	 for (w=0;w<W;w++)
	 {
	    for (l=0;l<q;l++)
	    {
	       for (k=0;k<p;k++)
	       {
		  for (s=0;s<d;s++)
		  {		  
		     rem = positiverem(k*M+s*p*M-l*h_a*a, L);
		     sbuf[2*s]   = fp[rem];
		     sbuf[2*s+1] = 0.0;
		  }
		  
		  LTFAT_FFTW(execute)(p_before);
		  
		  for (s=0;s<d;s++)
		  {		  
		     ffp[s*ld2a]   = sbuf[2*s]*scalconst;
		     ffp[s*ld2a+1] = sbuf[2*s+1]*scalconst;
		  }
		  ffp+=2;
	       }
	    }
	    fp+=L;
	 }
	 fp-=2*L*W;
      }

      /* ----------- compute matrix multiplication ----------- */

      /* Do the matmul  */
      if (p==1)
      {
	 /* Integer oversampling case */
	 

	 /* Rational oversampling case */
	 for (s=0;s<d;s++)
	 {	
	    gbase=(LTFAT_REAL*)gf+2*(r+s*c)*q;
	    fbase=ff+2*s*q*W;
	    cbase=cf+2*s*q*q*W;
	    
	    for (nm=0;nm<q*W;nm++)
	    {
	       for (mm=0;mm<q;mm++)
	       {
		  cbase[0]=gbase[0]*fbase[0]+gbase[1]*fbase[1];
		  cbase[1]=gbase[0]*fbase[1]-gbase[1]*fbase[0];
		  gbase+=2;
		  cbase+=2;
	       }			       
	       gbase-=2*q;
	       fbase+=2;
	    }
	    cbase-=2*q*q*W;
	 }

      }
      else
      {

	 /* Rational oversampling case */
	 for (s=0;s<d;s++)
	 {	
	    gbase=(LTFAT_REAL*)gf+2*(r+s*c)*p*q;
	    fbase=ff+2*s*p*q*W;
	    cbase=cf+2*s*q*q*W;
	    
	    for (nm=0;nm<q*W;nm++)
	    {
	       for (mm=0;mm<q;mm++)
	       {
		  cbase[0]=0.0;
		  cbase[1]=0.0;
		  for (km=0;km<p;km++)
		  {
		     cbase[0]+=gbase[0]*fbase[0]+gbase[1]*fbase[1];
		     cbase[1]+=gbase[0]*fbase[1]-gbase[1]*fbase[0];
		     gbase+=2;
		     fbase+=2;
		  }
		  fbase-=2*p;
		  cbase+=2;
	       }			       
	       gbase-=2*q*p;
	       fbase+=2*p;
	    }
	    cbase-=2*q*q*W;
	    fbase-=2*p*q*W;
	 }
      }



      /*  -------  compute inverse coefficient factorization ------- */
      cfp=cf;
      const int ld5c=M*N;

      /* Cover both integer and rational sampling case */
      for (w=0;w<W;w++)
      {
	 /* Complete inverse fac of coefficients */
	 for (l=0;l<q;l++)
	 {
	    for (u=0;u<q;u++)
	    {	       	       
	       for (s=0;s<d;s++)	       
	       {	
		  sbuf[2*s]   = cfp[s*ld3b];
		  sbuf[2*s+1] = cfp[s*ld3b+1];
	       }
	       cfp+=2;
	       
	       /* Do inverse fft of length d */
	       LTFAT_FFTW(execute)(p_after);
	       
	       for (s=0;s<d;s++)	       
	       {	
		  rem= r+l*c+positiverem(u+s*q-l*h_a,N)*M+w*ld5c;
		  cout[rem][0]=sbuf[2*s];
		  cout[rem][1]=sbuf[2*s+1];
	       }		    
	    }
	 }
      }            

      
      /* ----------- Main loop ends here ------------------------ */
   }     

    /* -----------  Clean up ----------------- */   
   LTFAT_FFTW(destroy_plan)(p_before);
   LTFAT_FFTW(destroy_plan)(p_after);

   ltfat_free(sbuf);
   ltfat_free(ff);
   ltfat_free(cf);
   
}


LTFAT_EXTERN void
LTFAT_NAME(dgtreal_walnut_plan)(LTFAT_NAME(dgtreal_long_plan) plan)
{



   /*  --------- initial declarations -------------- */

   const int a=plan.a;
   const int M=plan.M;
   const int L=plan.L;
   const int W=plan.W;
   const int N=L/a;
   const int c=plan.c;
   const int p=a/c;
   const int q=M/c;
   const int d=N/q;


   /* This is a floor operation. */
   const int d2= d/2+1;

   const LTFAT_REAL *f = plan.f;
   const LTFAT_COMPLEX *gf = (const LTFAT_COMPLEX *)plan.gf;
   
   const int h_a=plan.h_a;

   LTFAT_REAL *sbuf=plan.sbuf;
   LTFAT_COMPLEX *cbuf=plan.cbuf;

   LTFAT_REAL *cout=plan.cwork;

   
   LTFAT_REAL *gbase, *fbase, *cbase;

   LTFAT_REAL *ffp;

   const LTFAT_REAL *fp;

   /* Scaling constant needed because of FFTWs normalization. */
   const LTFAT_REAL scalconst=1.0/((LTFAT_REAL)d*sqrt((LTFAT_REAL)M));

   /* Leading dimensions of the 4dim array. */
   const int ld2a=2*p*q*W;

   /* Leading dimensions of cf */
   const int ld3b=2*q*q*W;

   /* --------- main loop begins here ------------------- */
   for (int r=0;r<c;r++)
   {            
      /*  ---------- compute signal factorization ----------- */
      ffp=plan.ff;
      fp=f+r;
      if (p==1)	
      {
	 /* Integer oversampling case */	 
	 for (int w=0;w<W;w++)
	 {
	    for (int l=0;l<q;l++)
	    {
	       for (int s=0;s<d;s++)
	       {		  
		  sbuf[s]   = fp[(s*M+l*a)%L];
	       }
	       
	       LTFAT_FFTW(execute)(plan.p_before);
	       
	       for (int s=0;s<d2;s++)
	       {		  
		 ffp[s*ld2a]   = cbuf[s][0]*scalconst;
		 ffp[s*ld2a+1] = cbuf[s][1]*scalconst;
	       }
	       ffp+=2;
	    }
	    fp+=L;
	 }
	 fp-=2*L*W;	 
      }
      else
      {      
	 /* rational sampling case */

	 for (int w=0;w<W;w++)
	 {
	    for (int l=0;l<q;l++)
	    {
	       for (int k=0;k<p;k++)
	       {
		  for (int s=0;s<d;s++)
		  {		  
		     sbuf[s]   = fp[ positiverem(k*M+s*p*M-l*h_a*a, L) ];
		  }
		  
		  LTFAT_FFTW(execute)(plan.p_before);
		  
		  for (int s=0;s<d2;s++)
		  {		  
		     ffp[s*ld2a]   = cbuf[s][0]*scalconst;
		     ffp[s*ld2a+1] = cbuf[s][1]*scalconst;
		  }
		  ffp+=2;
	       }
	    }
	    fp+=L;
	 }
	 fp-=2*L*W;
      }

      /* ----------- compute matrix multiplication ----------- */

      /* Do the matmul  */
      if (p==1)
      {
	 /* Integer oversampling case */
	 

	 /* Rational oversampling case */
	 for (int s=0;s<d2;s++)
	 {	
	    gbase=(LTFAT_REAL*)gf+2*(r+s*c)*q;
	    fbase=plan.ff+2*s*q*W;
	    cbase=plan.cf+2*s*q*q*W;
	    
	    for (int nm=0;nm<q*W;nm++)
	    {
	       for (int mm=0;mm<q;mm++)
	       {
		  cbase[0]=gbase[0]*fbase[0]+gbase[1]*fbase[1];
		  cbase[1]=gbase[0]*fbase[1]-gbase[1]*fbase[0];
		  gbase+=2;
		  cbase+=2;
	       }			       
	       gbase-=2*q;
	       fbase+=2;
	    }
	    cbase-=2*q*q*W;
	 }

      }
      else
      {

	 /* Rational oversampling case */
	 for (int s=0;s<d2;s++)
	 {	
	    gbase=(LTFAT_REAL*)gf+2*(r+s*c)*p*q;
	    fbase=plan.ff+2*s*p*q*W;
	    cbase=plan.cf+2*s*q*q*W;
	    
	    for (int nm=0;nm<q*W;nm++)
	    {
	       for (int mm=0;mm<q;mm++)
	       {
		  cbase[0]=0.0;
		  cbase[1]=0.0;
		  for (int km=0;km<p;km++)
		  {
		     cbase[0]+=gbase[0]*fbase[0]+gbase[1]*fbase[1];
		     cbase[1]+=gbase[0]*fbase[1]-gbase[1]*fbase[0];
		     gbase+=2;
		     fbase+=2;
		  }
		  fbase-=2*p;
		  cbase+=2;
	       }			       
	       gbase-=2*q*p;
	       fbase+=2*p;
	    }
	    cbase-=2*q*q*W;
	    fbase-=2*p*q*W;
	 }
      }



      /*  -------  compute inverse coefficient factorization ------- */
      LTFAT_REAL *cfp=plan.cf;
      const int ld5c=M*N;

      /* Cover both integer and rational sampling case */
      for (int w=0;w<W;w++)
      {
	 /* Complete inverse fac of coefficients */
	 for (int l=0;l<q;l++)
	 {
	    for (int u=0;u<q;u++)
	    {	       	       
	       for (int s=0;s<d2;s++)	       
	       {	
		  cbuf[s][0] = cfp[s*ld3b];
		  cbuf[s][1] = cfp[s*ld3b+1];
	       }
	       cfp+=2;
	       
	       /* Do inverse fft of length d */
	       LTFAT_FFTW(execute)(plan.p_after);
	       
	       for (int s=0;s<d;s++)	       
	       {	
		     cout[ r+l*c+positiverem(u+s*q-l*h_a,N)*M+w*ld5c ]=sbuf[s];
	       }		    
	    }
	 }
      }            

      
      /* ----------- Main loop ends here ------------------------ */
   }     
   
}
