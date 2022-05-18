subroutine seq_flds_getField(outfield, nfld, cstring)

! !USES:
   use mct_mod

! !INPUT/OUTPUT PARAMETERS:

   character(len=*),intent(out) :: outfield   ! output field name
   integer         ,intent(in ) :: nfld       ! field number
   character(len=*),intent(in ) :: cstring    ! colon delimited field string

!EOP

  type(mct_list)   :: mctIstr  ! mct list from input cstring
  type(mct_string) :: mctOStr  ! mct string for output outfield

!-------------------------------------------------------------------------------
!
!-------------------------------------------------------------------------------

  outfield = ' '

  call mct_list_init(mctIstr,cstring)
  call mct_list_get(mctOStr,nfld,mctIstr)
  outfield = mct_string_toChar(mctOStr)
  call mct_list_clean(mctIstr)
  call mct_string_clean(mctOStr)

end subroutine seq_flds_getField
