 module m_String

! !USES:
! No external modules are used in the declaration section of this module.
      implicit none

      public :: String

    Type String
      character(len=1),dimension(:),pointer :: c
    End Type String

      public :: toChar
      public :: clean
      public :: init

  interface toChar;  module procedure     &
     str2ch0_,     &
     ch12ch0_
  end interface

  interface clean; module procedure clean_; end interface
  interface init; module procedure initc_; end interface

  character(len=*),parameter :: myname='MCT(MPEU)::m_String'

contains

 subroutine initc_(str, chr)

! !USES:
!
 
      implicit none

! !INPUT PARAMETERS: 
!
      character(len=*), intent(in)  :: chr

! !OUTPUT PARAMETERS: 
!
      type(String),     intent(out) :: str

! !REVISION HISTORY:
!      23Apr98 - Jing Guo <guo@thunder> - initial prototype/prolog/code
!EOP ___________________________________________________________________

  character(len=*),parameter :: myname_=myname//'::initc_'
  integer :: ln,ier,i

  ln=len(chr)
  allocate(str%c(ln),stat=ier)

  do i=1,ln
    str%c(i)=chr(i:i)
  end do

 end subroutine initc_

 function str2ch0_(str)

! !USES:
!
! No external modules are used by this function.

     implicit none

! !INPUT PARAMETERS: 
!
     type(String),              intent(in) :: str

! !OUTPUT PARAMETERS: 
!
     character(len=size(str%c,1))            :: str2ch0_

! !REVISION HISTORY:
!      23Apr98 - Jing Guo <guo@thunder> - initial prototype/prolog/code
!EOP ___________________________________________________________________

  character(len=*),parameter :: myname_=myname//'::str2ch0_'
  integer :: i

  do i=1,size(str%c)
    str2ch0_(i:i)=str%c(i)
  end do

 end function str2ch0_

 function ch12ch0_(ch1)

! !USES:
!
! No external modules are used by this function.

      implicit none

! !INPUT PARAMETERS: 
!
      character(len=1), dimension(:), intent(in) :: ch1

! !OUTPUT PARAMETERS: 
!
      character(len=size(ch1,1))                   :: ch12ch0_

! !REVISION HISTORY:
!      22Apr98 - Jing Guo <guo@thunder> - initial prototype/prolog/code
!EOP ___________________________________________________________________

  character(len=*),parameter :: myname_=myname//'::ch12ch0_'
  integer :: i

  do i=1,size(ch1)
    ch12ch0_(i:i)=ch1(i)
  end do

 end function ch12ch0_

 subroutine clean_(str)

! !USES:
!

      implicit none

! !INPUT/OUTPUT PARAMETERS: 
!
      type(String), intent(inout) :: str

! !REVISION HISTORY:
!      23Apr98 - Jing Guo <guo@thunder> - initial prototype/prolog/code
!EOP ___________________________________________________________________

  character(len=*),parameter :: myname_=myname//'::clean_'
  integer :: ier

  deallocate(str%c,stat=ier)

 end subroutine clean_

 end module m_String
