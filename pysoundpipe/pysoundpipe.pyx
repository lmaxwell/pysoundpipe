from libc.stdint cimport uint32_t, int64_t, int32_t
import numpy as np

cdef extern from "soundpipe.h":
    ctypedef float SPFLOAT
    ctypedef struct sp_data: 
        SPFLOAT *out;
        int sr;
        int nchan;
        unsigned long len;
        unsigned long pos;
        char filename[200];
        uint32_t rand;
    int sp_create(sp_data **spp)
    int sp_destroy(sp_data **spp)

    ctypedef struct sp_ftbl:
        size_t size;
        uint32_t lobits;
        uint32_t lomask;
        SPFLOAT lodiv;
        SPFLOAT sicvt;
        SPFLOAT *tbl;
        char _cel "del";

    ctypedef struct sp_osc: 
        SPFLOAT freq, amp, iphs;
        int32_t   lphs;
        sp_ftbl *tbl;
        int inc;


    int sp_ftbl_create(sp_data *sp, sp_ftbl **ft, size_t size)
    int sp_ftbl_init(sp_data *sp, sp_ftbl *ft, size_t size)
    int sp_ftbl_bind(sp_data *sp, sp_ftbl **ft, SPFLOAT *tbl, size_t size)
    int sp_ftbl_destroy(sp_ftbl **ft)
    int sp_gen_vals(sp_data *sp, sp_ftbl *ft, const char *string)
    int sp_gen_sine(sp_data *sp, sp_ftbl *ft)
    int sp_gen_file(sp_data *sp, sp_ftbl *ft, const char *filename)
    int sp_gen_sinesum(sp_data *sp, sp_ftbl *ft, const char *argstring)
    int sp_gen_line(sp_data *sp, sp_ftbl *ft, const char *argstring)
    int sp_gen_xline(sp_data *sp, sp_ftbl *ft, const char *argstring)
    int sp_gen_gauss(sp_data *sp, sp_ftbl *ft, SPFLOAT scale, uint32_t seed)
    int sp_ftbl_loadfile(sp_data *sp, sp_ftbl **ft, const char *filename)
    int sp_ftbl_loadspa(sp_data *sp, sp_ftbl **ft, const char *filename)
    int sp_gen_composite(sp_data *sp, sp_ftbl *ft, const char *argstring)
    int sp_gen_rand(sp_data *sp, sp_ftbl *ft, const char *argstring)
    int sp_gen_triangle(sp_data *sp, sp_ftbl *ft)

    int sp_osc_create(sp_osc **osc)
    int sp_osc_destroy(sp_osc **osc)
    int sp_osc_init(sp_data *sp, sp_osc *osc, sp_ftbl *ft, SPFLOAT iphs)
    int sp_osc_compute(sp_data *sp, sp_osc *osc, SPFLOAT *_in, SPFLOAT *out)

    int sp_process(sp_data *sp, void *ud, void (*callback)(sp_data *, void *))
    int sp_process_raw(sp_data *sp, void *ud, void (*callback)(sp_data *, void *))
    int sp_out(sp_data *sp, uint32_t chan, SPFLOAT val)


"""
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "soundpipe.h"

typedef struct {
    sp_osc *osc;
    sp_ftbl *ft; 
    int counter;
} UserData;

void write_osc(sp_data *sp, void *udata) {
    UserData *ud = udata;
    SPFLOAT osc = 0;
    sp_osc_compute(sp, ud->osc, NULL, &osc);
    ud->counter = (ud->counter + 1) % 4410;
    sp_out(sp, 0, osc);
}

int main() {
    srand(time(NULL));
    UserData ud;
    ud.counter = 0;
    sp_data *sp;
    sp_create(&sp);
    sp_ftbl_create(sp, &ud.ft, 8192);
    sp_osc_create(&ud.osc);
    
    sp_gen_triangle(sp, ud.ft);
    sp_osc_init(sp, ud.osc, ud.ft, 0);
    ud.osc->freq = 500;
    sp->len = 44100 * 5;
    sp_process(sp, &ud, write_osc);

    sp_ftbl_destroy(&ud.ft);
    sp_osc_destroy(&ud.osc);
    sp_destroy(&sp);
    return 0;
}


"""
"""
void write_osc(sp_data *sp, void *udata) {
    UserData *ud = udata;
    SPFLOAT osc = 0;
    sp_osc_compute(sp, ud->osc, NULL, &osc);
    ud->counter = (ud->counter + 1) % 4410;
    sp_out(sp, 0, osc);
}
"""




ctypedef struct UserData:
    sp_osc *osc;
    sp_ftbl *ft; 
    int counter;

cdef void write_osc(sp_data *sp, void* udata):
    cdef UserData *ud = <UserData*> udata
    cdef SPFLOAT osc = 0 
    sp_osc_compute(sp,ud.osc,NULL,&osc)
    ud.counter=(ud.counter+1)%4410

    sp_out(sp,0,osc)

cdef class TEST:
    cdef SPFLOAT i
    cdef sp_data *sp
    cdef UserData ud
    def __cinit__(self):
        sp_create(&self.sp)

        sp_ftbl_create(self.sp,&self.ud.ft,8192)
        sp_osc_create(&self.ud.osc)

        sp_gen_triangle(self.sp,self.ud.ft)
        sp_osc_init(self.sp,self.ud.osc,self.ud.ft,0)
        self.ud.osc.freq=500
        self.sp.len=44100*5

        wavedata=np.array([])

        sp_process(self.sp,<void *>&self.ud,write_osc)
    def __dealloc__(self):
        sp_ftbl_destroy(&self.ud.ft)
        sp_osc_destroy(&self.ud.osc)
        sp_destroy(&self.sp)


