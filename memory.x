  /* This memory map assumes the flash cache is on; 
     the blocks used are excluded from the various memory ranges 
     
     see: https://github.com/espressif/esp-idf/blob/master/components/soc/src/esp32/soc_memory_layout.c
     for details
     */

RESERVE_DRAM = 0;
RESERVE_RTC_FAST = 0;
RESERVE_RTC_SLOW = 0;

SECTIONS {
  .rwtext :
  {
    *(.rwtext.literal .rwtext .rwtext.literal.* .rwtext.*)
  } > iram_seg
}

/* Specify main memory areas */
MEMORY
{
  
  reserved1_seg ( RWX )  : ORIGIN = 0x40070000, len = 0x10000 /* SRAM0 64kB; reserved for usage as flash cache*/
  vectors ( RX )         : ORIGIN = 0x40080000, len = 0x400 /* SRAM0 1kB */
  iram_seg ( RX )        : ORIGIN = 0x40080400, len = 0x20000-0x400 /* SRAM0 127kB */

  reserved2_seg ( RW )   : ORIGIN = 0x3FFAE000, len = 0x2000 /* SRAM2 8kB; reserved for usage by the ROM */
  dram_seg ( RW )        : ORIGIN = 0x3FFB0000 + RESERVE_DRAM, len = 0x2c200 - RESERVE_DRAM /* SRAM2+1 176.5kB; first 64kB used by BT if enable */
  reserved3_seg ( RW )   : ORIGIN = 0x3FFDC200, len = 0x23e00 /* SRAM1 143.5kB; reserved for static ROM usage; can be used for heap */

  /* external flash 
     The 0x20 offset is a convenience for the app binary image generation.
     Flash cache has 64KB pages. The .bin file which is flashed to the chip
     has a 0x18 byte file header, and each segment has a 0x08 byte segment
     header. Setting this offset makes it simple to meet the flash cache MMU's
     constraint that (paddr % 64KB == vaddr % 64KB).)
  */
  irom_seg ( RX )        : ORIGIN = 0x400D8020, len = 0x330000-0x20 /* 3MB */
  drom_seg ( R )         : ORIGIN = 0x3F400020, len = 0x400000-0x20 /* 4MB */


  /* RTC fast memory (executable). Persists over deep sleep. Only for core 0 (PRO_CPU) */
  rtc_fast_iram_seg(RWX) : ORIGIN = 0x400C0000, len = 0x2000 /* 8kB */

  /* RTC fast memory (same block as above), viewed from data bus. Only for core 0 (PRO_CPU) */
  rtc_fast_dram_seg(RW)  : ORIGIN = 0x3ff80000 + RESERVE_RTC_FAST, len = 0x2000 - RESERVE_RTC_FAST /* 8kB */

  /* RTC slow memory (data accessible). Persists over deep sleep. */
  rtc_slow_seg(RW)       : ORIGIN = 0x50000000 + RESERVE_RTC_SLOW, len = 0x2000 - RESERVE_RTC_SLOW /* 8kB */

  /* external memory, including data and text, 
     4MB is the maximum, if external psram is bigger, paging is required */
  psram_seg(RWX)         : ORIGIN = 0x3F800000, len = 0x400000 /* 4MB */
}

REGION_ALIAS("ROTEXT", irom_seg);
REGION_ALIAS("RODATA", drom_seg);
REGION_ALIAS("RWDATA", dram_seg);