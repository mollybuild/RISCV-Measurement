module m_List

      implicit none

      public :: List
      public :: init
      public :: clean
      public :: get

      Type List
      character(len=1),dimension(:),pointer :: bf
      integer,       dimension(:,:),pointer :: lc
      End Type List

  interface init ; module procedure init_; end interface

  interface clean; module procedure clean_; end interface

  interface get  ; module procedure get_; end interface

  character(len=*),parameter :: myname='MCT(MPEU)::m_List'

contains

 subroutine init_(aList,Values)

! !USES:
!
      implicit none

! !INPUT PARAMETERS: 
!
      character(len=*),intent(in) :: Values ! ":" delimited names

! !OUTPUT PARAMETERS:   
!
      type(List),intent(out)       :: aList  ! an indexed string values
 

! !REVISION HISTORY:
! 22Apr98 - Jing Guo <guo@thunder> - initial prototype/prolog/code
!EOP ___________________________________________________________________

  character(len=*),parameter :: myname_=myname//'::init_'
  character(len=1) :: c
  integer :: ib,ie,id,lb,le,ni,i,ier

     ! Pass 1, getting the sizes
  le=0
  ni=0
  ib=1
  ie=0
  id=0
  do i=1,len(Values)
    c=Values(i:i)
    select case(c)
    case(' ')
      if(ib==i) ib=i+1     ! moving ib up, starting from the next
    case(':')
      if(ib<=ie) then
     ni=ni+1
     id=1          ! mark a ':'
      endif
      ib=i+1          ! moving ib up, starting from the next
    case default
      ie=i
      if(id==1) then     ! count an earlier marked ':'
     id=0
     le=le+1
      endif
      le=le+1
    end select
  end do
  if(ib<=ie) ni=ni+1

  ! COMPILER MAY NOT SIGNAL AN ERROR IF 
  ! ALIST HAS ALREADY BEEN INITIALIZED.
  ! PLEASE CHECK FOR PREVIOUS INITIALIZATION
  
  allocate(aList%bf(le),aList%lc(0:1,ni),stat=ier)

     ! Pass 2, copy the value and assign the pointers
  lb=1
  le=0
  ni=0
  ib=1
  ie=0
  id=0
  do i=1,len(Values)
    c=Values(i:i)

    select case(c)
    case(' ')
      if(ib==i) ib=i+1     ! moving ib up, starting from the next
    case(':')
      if(ib<=ie) then
     ni=ni+1
     aList%lc(0:1,ni)=(/lb,le/)
     id=1          ! mark a ':'
      endif

      ib=i+1          ! moving ib up, starting from the next
      lb=le+2          ! skip to the next non-':' and non-','
    case default
      ie=i
      if(id==1) then     ! copy an earlier marked ':'
     id=0
     le=le+1
        aList%bf(le)=':'
      endif

      le=le+1
      aList%bf(le)=c
    end select
  end do
  if(ib<=ie) then
    ni=ni+1
    aList%lc(0:1,ni)=(/lb,le/)
  endif

 end subroutine init_

 subroutine clean_(aList, stat)

! !USES:
!

      implicit none

! !INPUT/OUTPUT PARAMETERS: 
!
      type(List),        intent(inout) :: aList

! !OUTPUT PARAMETERS:   
!
      integer, optional, intent(out)   :: stat

! !REVISION HISTORY:
! 22Apr98 - Jing Guo <guo@thunder> - initial prototype/prolog/code
!  1Mar02 - E.T. Ong <eong@mcs.anl.gov> - added stat argument and
!           removed die to prevent crashes.
!EOP ___________________________________________________________________

  character(len=*),parameter :: myname_=myname//'::clean_'
  integer :: ier

  if(associated(aList%bf) .and. associated(aList%lc)) then

     deallocate(aList%bf, aList%lc, stat=ier)

     if(present(stat)) then
     stat=ier
     endif

  endif

 end subroutine clean_

 subroutine get_(itemStr, ith, aList)

! !USES:
!
      use m_String, only : String, init, toChar

      implicit none

! !INPUT PARAMETERS: 
!
      integer,     intent(in)  :: ith
      type(List),  intent(in)  :: aList

! !OUTPUT PARAMETERS:   
!
      type(String),intent(out) :: itemStr


! !REVISION HISTORY:
! 23Apr98 - Jing Guo <guo@thunder> - initial prototype/prolog/code
! 14May07 - Larson, Jacob - add space to else case string so function
!                           matches documentation.
!EOP ___________________________________________________________________

  character(len=*),parameter :: myname_=myname//'::get_'
  integer :: lb,le

  if(ith>0 .and. ith <= size(aList%lc,2)) then
    lb=aList%lc(0,ith)
    le=aList%lc(1,ith)
    call init(itemStr,toChar(aList%bf(lb:le)))
  endif

 end subroutine get_


end module m_List
