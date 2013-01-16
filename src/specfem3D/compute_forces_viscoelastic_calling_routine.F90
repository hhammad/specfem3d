!=====================================================================
!
!               S p e c f e m 3 D  V e r s i o n  2 . 1
!               ---------------------------------------
!
!          Main authors: Dimitri Komatitsch and Jeroen Tromp
!    Princeton University, USA and CNRS / INRIA / University of Pau
! (c) Princeton University / California Institute of Technology and CNRS / INRIA / University of Pau
!                             July 2012
!
! This program is free software; you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation; either version 2 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License along
! with this program; if not, write to the Free Software Foundation, Inc.,
! 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
!
!=====================================================================

! elastic solver

subroutine compute_forces_viscoelastic()

  use specfem_par
  use specfem_par_acoustic
  use specfem_par_elastic
  use specfem_par_poroelastic
  use fault_solver_dynamic, only : bc_dynflt_set3d_all,SIMULATION_TYPE_DYN
  use fault_solver_kinematic, only : bc_kinflt_set_all,SIMULATION_TYPE_KIN

  implicit none

  integer:: iphase
  logical:: phase_is_inner

! distinguishes two runs: for points on MPI interfaces, and points within the partitions
  do iphase=1,2

    !first for points on MPI interfaces
    if( iphase == 1 ) then
      phase_is_inner = .false.
    else
      phase_is_inner = .true.
    endif


! elastic term
    if( .NOT. GPU_MODE ) then
      if(USE_DEVILLE_PRODUCTS) then
        ! uses Deville (2002) optimizations
        call compute_forces_viscoelastic_Dev_sim1(iphase)

        ! adjoint simulations: backward/reconstructed wavefield
        if( SIMULATION_TYPE == 3 ) &
          call compute_forces_viscoelastic_Dev_sim3(iphase)

      else
        ! no optimizations used
        call compute_forces_viscoelastic_noDev( iphase, NSPEC_AB,NGLOB_AB,displ,veloc,accel, &
                        xix,xiy,xiz,etax,etay,etaz,gammax,gammay,gammaz, &
                        hprime_xx,hprime_yy,hprime_zz, &
                        hprimewgll_xx,hprimewgll_yy,hprimewgll_zz, &
                        wgllwgll_xy,wgllwgll_xz,wgllwgll_yz, &
                        kappastore,mustore,jacobian,ibool, &
                        ATTENUATION,deltat,PML_CONDITIONS, &
                        nspec2D_xmin,nspec2D_xmax,nspec2D_ymin,nspec2D_ymax,NSPEC2D_BOTTOM,NSPEC2D_TOP, &
                        ibelm_xmin,ibelm_xmax,ibelm_ymin,ibelm_ymax,ibelm_bottom,ibelm_top, &
                        one_minus_sum_beta,factor_common, &
                        alphaval,betaval,gammaval,&
                        NSPEC_ATTENUATION_AB, &
                        R_xx,R_yy,R_xy,R_xz,R_yz, &
                        epsilondev_xx,epsilondev_yy,epsilondev_xy, &
                        epsilondev_xz,epsilondev_yz,epsilon_trace_over_3, &
                        ANISOTROPY,NSPEC_ANISO, &
                        c11store,c12store,c13store,c14store,c15store,c16store, &
                        c22store,c23store,c24store,c25store,c26store,c33store, &
                        c34store,c35store,c36store,c44store,c45store,c46store, &
                        c55store,c56store,c66store, &
                        SIMULATION_TYPE,COMPUTE_AND_STORE_STRAIN,NSPEC_STRAIN_ONLY, &
                        NSPEC_BOUN,NSPEC2D_MOHO,NSPEC_ADJOINT, &
                        is_moho_top,is_moho_bot, &
                        dsdx_top,dsdx_bot, &
                        ispec2D_moho_top,ispec2D_moho_bot, &
                        num_phase_ispec_elastic,nspec_inner_elastic,nspec_outer_elastic, &
                        phase_ispec_inner_elastic,ispec_is_elastic )

        ! adjoint simulations: backward/reconstructed wavefield
        if( SIMULATION_TYPE == 3 ) &
          call compute_forces_viscoelastic_noDev( iphase, NSPEC_AB,NGLOB_AB, &
                        b_displ,b_veloc,b_accel, &
                        xix,xiy,xiz,etax,etay,etaz,gammax,gammay,gammaz, &
                        hprime_xx,hprime_yy,hprime_zz, &
                        hprimewgll_xx,hprimewgll_yy,hprimewgll_zz, &
                        wgllwgll_xy,wgllwgll_xz,wgllwgll_yz, &
                        kappastore,mustore,jacobian,ibool, &
                        ATTENUATION,deltat,PML_CONDITIONS, &
                        nspec2D_xmin,nspec2D_xmax,nspec2D_ymin,nspec2D_ymax,NSPEC2D_BOTTOM,NSPEC2D_TOP, &
                        ibelm_xmin,ibelm_xmax,ibelm_ymin,ibelm_ymax,ibelm_bottom,ibelm_top, &
                        one_minus_sum_beta,factor_common, &
                        b_alphaval,b_betaval,b_gammaval, &
                        NSPEC_ATTENUATION_AB, &
                        b_R_xx,b_R_yy,b_R_xy,b_R_xz,b_R_yz, &
                        b_epsilondev_xx,b_epsilondev_yy,b_epsilondev_xy, &
                        b_epsilondev_xz,b_epsilondev_yz,b_epsilon_trace_over_3, &
                        ANISOTROPY,NSPEC_ANISO, &
                        c11store,c12store,c13store,c14store,c15store,c16store, &
                        c22store,c23store,c24store,c25store,c26store,c33store, &
                        c34store,c35store,c36store,c44store,c45store,c46store, &
                        c55store,c56store,c66store, &
                        SIMULATION_TYPE,COMPUTE_AND_STORE_STRAIN,NSPEC_STRAIN_ONLY, &
                        NSPEC_BOUN,NSPEC2D_MOHO,NSPEC_ADJOINT, &
                        is_moho_top,is_moho_bot, &
                        b_dsdx_top,b_dsdx_bot, &
                        ispec2D_moho_top,ispec2D_moho_bot, &
                        num_phase_ispec_elastic,nspec_inner_elastic,nspec_outer_elastic, &
                        phase_ispec_inner_elastic  )

      endif

    else
      ! on GPU
      ! contains both forward SIM_TYPE==1 and backward SIM_TYPE==3 simulations
      call compute_forces_viscoelastic_cuda(Mesh_pointer, iphase, deltat, &
                                      nspec_outer_elastic, &
                                      nspec_inner_elastic, &
                                      COMPUTE_AND_STORE_STRAIN,ATTENUATION,ANISOTROPY)

      if(phase_is_inner .eqv. .true.) then
         ! while Inner elements compute "Kernel_2", we wait for MPI to
         ! finish and transfer the boundary terms to the device
         ! asynchronously

         !daniel: todo - this avoids calling the fortran vector send from CUDA routine
         ! wait for asynchronous copy to finish
         call sync_copy_from_device(Mesh_pointer,iphase,buffer_send_vector_ext_mesh)
         ! sends mpi buffers
         call assemble_MPI_vector_send_cuda(NPROC, &
                  buffer_send_vector_ext_mesh,buffer_recv_vector_ext_mesh, &
                  num_interfaces_ext_mesh,max_nibool_interfaces_ext_mesh, &
                  nibool_interfaces_ext_mesh,&
                  my_neighbours_ext_mesh, &
                  request_send_vector_ext_mesh,request_recv_vector_ext_mesh)

         ! transfers mpi buffers onto GPU
         call transfer_boundary_to_device(NPROC,Mesh_pointer,buffer_recv_vector_ext_mesh, &
                  num_interfaces_ext_mesh,max_nibool_interfaces_ext_mesh, &
                  request_recv_vector_ext_mesh)
      endif ! inner elements

   endif ! GPU_MODE


! adds elastic absorbing boundary term to acceleration (Stacey conditions)
    if( ABSORBING_CONDITIONS ) then
       call compute_stacey_viscoelastic(NSPEC_AB,NGLOB_AB,accel, &
                        ibool,ispec_is_inner,phase_is_inner, &
                        abs_boundary_normal,abs_boundary_jacobian2Dw, &
                        abs_boundary_ijk,abs_boundary_ispec, &
                        num_abs_boundary_faces, &
                        veloc,rho_vp,rho_vs, &
                        ispec_is_elastic,SIMULATION_TYPE,SAVE_FORWARD, &
                        NSTEP,it,NGLOB_ADJOINT,b_accel, &
                        b_num_abs_boundary_faces,b_reclen_field,b_absorb_field,&
                        GPU_MODE,Mesh_pointer)
    endif


! acoustic coupling
    if( ACOUSTIC_SIMULATION ) then
      if( num_coupling_ac_el_faces > 0 ) then
        if( .NOT. GPU_MODE ) then
          if( SIMULATION_TYPE == 1 ) then
            ! forward definition: pressure=-potential_dot_dot
            call compute_coupling_viscoelastic_ac(NSPEC_AB,NGLOB_AB, &
                        ibool,accel,potential_dot_dot_acoustic, &
                        num_coupling_ac_el_faces, &
                        coupling_ac_el_ispec,coupling_ac_el_ijk, &
                        coupling_ac_el_normal, &
                        coupling_ac_el_jacobian2Dw, &
                        ispec_is_inner,phase_is_inner)
          else
            ! handles adjoint runs coupling between adjoint potential and adjoint elastic wavefield
            ! adoint definition: pressure^\dagger=potential^\dagger
            call compute_coupling_viscoelastic_ac(NSPEC_AB,NGLOB_AB, &
                              ibool,accel,-potential_acoustic_adj_coupling, &
                              num_coupling_ac_el_faces, &
                              coupling_ac_el_ispec,coupling_ac_el_ijk, &
                              coupling_ac_el_normal, &
                              coupling_ac_el_jacobian2Dw, &
                              ispec_is_inner,phase_is_inner)
          endif

        ! adjoint simulations
        if( SIMULATION_TYPE == 3 ) &
          call compute_coupling_viscoelastic_ac(NSPEC_ADJOINT,NGLOB_ADJOINT, &
                        ibool,b_accel,b_potential_dot_dot_acoustic, &
                        num_coupling_ac_el_faces, &
                        coupling_ac_el_ispec,coupling_ac_el_ijk, &
                        coupling_ac_el_normal, &
                        coupling_ac_el_jacobian2Dw, &
                        ispec_is_inner,phase_is_inner)

        else
          ! on GPU
          call compute_coupling_el_ac_cuda(Mesh_pointer,phase_is_inner, &
                                           num_coupling_ac_el_faces)
        endif ! GPU_MODE
      endif ! num_coupling_ac_el_faces
    endif


! poroelastic coupling
    if( POROELASTIC_SIMULATION ) then
      call compute_coupling_viscoelastic_po(NSPEC_AB,NGLOB_AB,ibool,&
                        displs_poroelastic,displw_poroelastic,&
                        xix,xiy,xiz,etax,etay,etaz,gammax,gammay,gammaz, &
                        hprime_xx,hprime_yy,hprime_zz,&
                        kappaarraystore,rhoarraystore,mustore, &
                        phistore,tortstore,jacobian,&
                        displ,accel,kappastore, &
                        ANISOTROPY,NSPEC_ANISO, &
                        c11store,c12store,c13store,c14store,c15store,c16store,&
                        c22store,c23store,c24store,c25store,c26store,c33store,&
                        c34store,c35store,c36store,c44store,c45store,c46store,&
                        c55store,c56store,c66store, &
                        SIMULATION_TYPE,NGLOB_ADJOINT,NSPEC_ADJOINT, &
                        num_coupling_el_po_faces, &
                        coupling_el_po_ispec,coupling_po_el_ispec, &
                        coupling_el_po_ijk,coupling_po_el_ijk, &
                        coupling_el_po_normal, &
                        coupling_el_po_jacobian2Dw, &
                        ispec_is_inner,phase_is_inner)
    endif

! adds source term (single-force/moment-tensor solution)
    call compute_add_sources_viscoelastic( NSPEC_AB,NGLOB_AB,accel, &
                        ibool,ispec_is_inner,phase_is_inner, &
                        NSOURCES,myrank,it,islice_selected_source,ispec_selected_source,&
                        hdur,hdur_gaussian,tshift_src,dt,t0,sourcearrays, &
                        ispec_is_elastic,SIMULATION_TYPE,NSTEP,NGLOB_ADJOINT, &
                        nrec,islice_selected_rec,ispec_selected_rec, &
                        nadj_rec_local,adj_sourcearrays,b_accel, &
                        NTSTEP_BETWEEN_READ_ADJSRC,NOISE_TOMOGRAPHY, &
                        GPU_MODE, Mesh_pointer )

    ! assemble all the contributions between slices using MPI
    if( phase_is_inner .eqv. .false. ) then
       ! sends accel values to corresponding MPI interface neighbors
       if(.NOT. GPU_MODE) then
          call assemble_MPI_vector_ext_mesh_s(NPROC,NGLOB_AB,accel, &
               buffer_send_vector_ext_mesh,buffer_recv_vector_ext_mesh, &
               num_interfaces_ext_mesh,max_nibool_interfaces_ext_mesh, &
               nibool_interfaces_ext_mesh,ibool_interfaces_ext_mesh,&
               my_neighbours_ext_mesh, &
               request_send_vector_ext_mesh,request_recv_vector_ext_mesh)
       else ! GPU_MODE==1
          ! transfers boundary region to host asynchronously. The
          ! MPI-send is done from within compute_forces_viscoelastic_cuda,
          ! once the inner element kernels are launched, and the
          ! memcpy has finished. see compute_forces_viscoelastic_cuda:1655
          call transfer_boundary_from_device_a(Mesh_pointer,nspec_outer_elastic)
       endif ! GPU_MODE

       ! adjoint simulations
       if( SIMULATION_TYPE == 3 ) then
          if(.NOT. GPU_MODE) then
             call assemble_MPI_vector_ext_mesh_s(NPROC,NGLOB_ADJOINT,b_accel, &
                  b_buffer_send_vector_ext_mesh,b_buffer_recv_vector_ext_mesh, &
                  num_interfaces_ext_mesh,max_nibool_interfaces_ext_mesh, &
                  nibool_interfaces_ext_mesh,ibool_interfaces_ext_mesh,&
                  my_neighbours_ext_mesh, &
                  b_request_send_vector_ext_mesh,b_request_recv_vector_ext_mesh)
          else ! GPU_MODE == 1
             call transfer_boun_accel_from_device(NGLOB_AB*NDIM, Mesh_pointer, b_accel,&
                       b_buffer_send_vector_ext_mesh,&
                       num_interfaces_ext_mesh, max_nibool_interfaces_ext_mesh,&
                       nibool_interfaces_ext_mesh, ibool_interfaces_ext_mesh,3) ! <-- 3 == adjoint b_accel
             call assemble_MPI_vector_send_cuda(NPROC, &
                  b_buffer_send_vector_ext_mesh,b_buffer_recv_vector_ext_mesh, &
                  num_interfaces_ext_mesh,max_nibool_interfaces_ext_mesh, &
                  nibool_interfaces_ext_mesh,&
                  my_neighbours_ext_mesh, &
                  b_request_send_vector_ext_mesh,b_request_recv_vector_ext_mesh)
          endif ! GPU
       endif !adjoint

    else
      ! waits for send/receive requests to be completed and assembles values
      if(.NOT. GPU_MODE) then
         call assemble_MPI_vector_ext_mesh_w_ordered(NPROC,NGLOB_AB,accel, &
                            buffer_recv_vector_ext_mesh,num_interfaces_ext_mesh,&
                            max_nibool_interfaces_ext_mesh, &
                            nibool_interfaces_ext_mesh,ibool_interfaces_ext_mesh, &
                            request_send_vector_ext_mesh,request_recv_vector_ext_mesh, &
                            my_neighbours_ext_mesh,myrank)

      else ! GPU_MODE == 1
         call assemble_MPI_vector_write_cuda(NPROC,NGLOB_AB,accel, Mesh_pointer,&
                            buffer_recv_vector_ext_mesh,num_interfaces_ext_mesh,&
                            max_nibool_interfaces_ext_mesh, &
                            nibool_interfaces_ext_mesh,ibool_interfaces_ext_mesh, &
                            request_send_vector_ext_mesh,request_recv_vector_ext_mesh,1)
      endif
      ! adjoint simulations
      if( SIMULATION_TYPE == 3 ) then
         if(.NOT. GPU_MODE) then
            call assemble_MPI_vector_ext_mesh_w_ordered(NPROC,NGLOB_ADJOINT,b_accel, &
                             b_buffer_recv_vector_ext_mesh,num_interfaces_ext_mesh,&
                             max_nibool_interfaces_ext_mesh, &
                             nibool_interfaces_ext_mesh,ibool_interfaces_ext_mesh, &
                             b_request_send_vector_ext_mesh,b_request_recv_vector_ext_mesh, &
                             my_neighbours_ext_mesh,myrank)

         else ! GPU_MODE == 1
            call assemble_MPI_vector_write_cuda(NPROC,NGLOB_AB,b_accel, Mesh_pointer,&
                              b_buffer_recv_vector_ext_mesh,num_interfaces_ext_mesh,&
                              max_nibool_interfaces_ext_mesh, &
                              nibool_interfaces_ext_mesh,ibool_interfaces_ext_mesh, &
                              b_request_send_vector_ext_mesh,b_request_recv_vector_ext_mesh,3)
         endif
      endif !adjoint

    endif

    !! DK DK May 2009: removed this because now each slice of a CUBIT + SCOTCH mesh
    !! DK DK May 2009: has a different number of spectral elements and therefore
    !! DK DK May 2009: only the general non-blocking MPI routines assemble_MPI_vector_ext_mesh_s
    !! DK DK May 2009: and assemble_MPI_vector_ext_mesh_w above can be used.
    !! DK DK May 2009: For adjoint runs below (SIMULATION_TYPE == 3) they should be used as well.

 enddo

!Percy , Fault boundary term B*tau is added to the assembled forces 
!        which at this point are stored in the array 'accel'
  if (SIMULATION_TYPE_DYN) call bc_dynflt_set3d_all(accel,veloc,displ)
  
  if (SIMULATION_TYPE_KIN) call bc_kinflt_set_all(accel,veloc,displ)

 ! multiplies with inverse of mass matrix (note: rmass has been inverted already)
 if(.NOT. GPU_MODE) then
    accel(1,:) = accel(1,:)*rmassx(:)
    accel(2,:) = accel(2,:)*rmassy(:)
    accel(3,:) = accel(3,:)*rmassz(:)
    ! adjoint simulations
    if (SIMULATION_TYPE == 3) then
       b_accel(1,:) = b_accel(1,:)*rmassx(:)
       b_accel(2,:) = b_accel(2,:)*rmassy(:)
       b_accel(3,:) = b_accel(3,:)*rmassz(:)
    endif !adjoint
 else ! GPU_MODE == 1
    call kernel_3_a_cuda(Mesh_pointer, NGLOB_AB, deltatover2,b_deltatover2,OCEANS)
 endif

! updates acceleration with ocean load term
  if(OCEANS) then
    if( .NOT. GPU_MODE ) then
      call compute_coupling_ocean(NSPEC_AB,NGLOB_AB, &
                                  ibool,rmassx,rmassy,rmassz, &
                                  rmass_ocean_load,accel, &
                                  free_surface_normal,free_surface_ijk,free_surface_ispec, &
                                  num_free_surface_faces,SIMULATION_TYPE, &
                                  NGLOB_ADJOINT,b_accel)
    else
      ! on GPU
      call compute_coupling_ocean_cuda(Mesh_pointer)
    endif
  endif

! updates velocities
! Newmark finite-difference time scheme with elastic domains:
! (see e.g. Hughes, 1987; Chaljub et al., 2003)
!
! u(t+delta_t) = u(t) + delta_t  v(t) + 1/2  delta_t**2 a(t)
! v(t+delta_t) = v(t) + 1/2 delta_t a(t) + 1/2 delta_t a(t+delta_t)
! a(t+delta_t) = 1/M_elastic ( -K_elastic u(t+delta) + B_elastic chi_dot_dot(t+delta_t) + f( t+delta_t) )
!
! where
!   u, v, a are displacement,velocity & acceleration
!   M is mass matrix, K stiffness matrix and B boundary term for acoustic/elastic domains
!   f denotes a source term (acoustic/elastic)
!   chi_dot_dot is acoustic (fluid) potential ( dotted twice with respect to time)
!
! corrector:
!   updates the velocity term which requires a(t+delta)
! GPU_MODE: this is handled in 'kernel_3' at the same time as accel*rmass
  if(.NOT. GPU_MODE) then
     veloc(:,:) = veloc(:,:) + deltatover2*accel(:,:)
     ! adjoint simulations
     if (SIMULATION_TYPE == 3) b_veloc(:,:) = b_veloc(:,:) + b_deltatover2*b_accel(:,:)
  else ! GPU_MODE == 1
    if( OCEANS ) call kernel_3_b_cuda(Mesh_pointer, NGLOB_AB, deltatover2,b_deltatover2)
  endif


end subroutine compute_forces_viscoelastic


!
!-------------------------------------------------------------------------------------------------
!

! distributes routines according to chosen NGLLX in constants.h

!daniel: note -- i put it here rather than in compute_forces_viscoelastic_Dev.f90 because compiler complains that:
! " The storage extent of the dummy argument exceeds that of the actual argument. "

subroutine compute_forces_viscoelastic_Dev_sim1(iphase)

! forward simulations

  use specfem_par
  use specfem_par_acoustic
  use specfem_par_elastic
  use specfem_par_poroelastic

  implicit none

  integer,intent(in) :: iphase

  select case(NGLLX)

  case (5)

!----------------------------------------------------------------------------------------------

! OpenMP routine flag for testing & benchmarking forward runs only
! configure additional flag, e.g.: FLAGS_NO_CHECK="-O3 -DOPENMP_MODE -openmp"

!----------------------------------------------------------------------------------------------
#ifdef OPENMP_MODE
!! DK DK Jan 2013: beware, that OpenMP version is not maintained / supported and thus probably does not work
    call compute_forces_viscoelastic_Dev_openmp(iphase, NSPEC_AB,NGLOB_AB,displ,veloc,accel, &
           xix,xiy,xiz,etax,etay,etaz,gammax,gammay,gammaz, &
           hprime_xx,hprime_xxT,hprimewgll_xx,hprimewgll_xxT, &
           wgllwgll_xy,wgllwgll_xz,wgllwgll_yz, &
           kappastore,mustore,jacobian,ibool, &
           ATTENUATION,deltat, &
           one_minus_sum_beta,factor_common, &
           alphaval,betaval,gammaval, &
           NSPEC_ATTENUATION_AB, &
           R_xx,R_yy,R_xy,R_xz,R_yz, &
           epsilondev_xx,epsilondev_yy,epsilondev_xy, &
           epsilondev_xz,epsilondev_yz,epsilon_trace_over_3, &
           ANISOTROPY,NSPEC_ANISO, &
           c11store,c12store,c13store,c14store,c15store,c16store,&
           c22store,c23store,c24store,c25store,c26store,c33store,&
           c34store,c35store,c36store,c44store,c45store,c46store,&
           c55store,c56store,c66store, &
           SIMULATION_TYPE, COMPUTE_AND_STORE_STRAIN,NSPEC_STRAIN_ONLY, &
           NSPEC_BOUN,NSPEC2D_MOHO,NSPEC_ADJOINT,&
           is_moho_top,is_moho_bot, &
           dsdx_top,dsdx_bot, &
           ispec2D_moho_top,ispec2D_moho_bot, &
           num_phase_ispec_elastic,&
           phase_ispec_inner_elastic,&
           num_colors_outer_elastic,num_colors_inner_elastic)
#else
    call compute_forces_viscoelastic_Dev_5p(iphase, NSPEC_AB,NGLOB_AB,displ,veloc,accel, &
             xix,xiy,xiz,etax,etay,etaz,gammax,gammay,gammaz, &
             hprime_xx,hprime_xxT,hprimewgll_xx,hprimewgll_xxT, &
             wgllwgll_xy,wgllwgll_xz,wgllwgll_yz, &
             kappastore,mustore,jacobian,ibool, &
             ATTENUATION,deltat, &
             one_minus_sum_beta,factor_common, &
             alphaval,betaval,gammaval, &
             NSPEC_ATTENUATION_AB, &
             R_xx,R_yy,R_xy,R_xz,R_yz, &
             epsilondev_xx,epsilondev_yy,epsilondev_xy, &
             epsilondev_xz,epsilondev_yz,epsilon_trace_over_3, &
             ANISOTROPY,NSPEC_ANISO, &
             c11store,c12store,c13store,c14store,c15store,c16store,&
             c22store,c23store,c24store,c25store,c26store,c33store,&
             c34store,c35store,c36store,c44store,c45store,c46store,&
             c55store,c56store,c66store, &
             SIMULATION_TYPE, COMPUTE_AND_STORE_STRAIN,NSPEC_STRAIN_ONLY, &
             NSPEC_BOUN,NSPEC2D_MOHO,NSPEC_ADJOINT,&
             is_moho_top,is_moho_bot, &
             dsdx_top,dsdx_bot, &
             ispec2D_moho_top,ispec2D_moho_bot, &
             num_phase_ispec_elastic,nspec_inner_elastic,nspec_outer_elastic,&
             phase_ispec_inner_elastic )
#endif

  case default

    stop 'error no Deville routine available for chosen NGLLX'

  end select

end subroutine compute_forces_viscoelastic_Dev_sim1

!
!-------------------------------------------------------------------------------------------------
!


subroutine compute_forces_viscoelastic_Dev_sim3(iphase)

! uses backward/reconstructed displacement and acceleration arrays

  use specfem_par
  use specfem_par_acoustic
  use specfem_par_elastic
  use specfem_par_poroelastic

  implicit none

  integer,intent(in) :: iphase

  select case(NGLLX)

  case (5)
    call compute_forces_viscoelastic_Dev_5p(iphase, NSPEC_AB,NGLOB_AB, &
                  b_displ,b_veloc,b_accel, &
                  xix,xiy,xiz,etax,etay,etaz,gammax,gammay,gammaz, &
                  hprime_xx,hprime_xxT,hprimewgll_xx,hprimewgll_xxT, &
                  wgllwgll_xy,wgllwgll_xz,wgllwgll_yz, &
                  kappastore,mustore,jacobian,ibool, &
                  ATTENUATION,deltat, &
                  one_minus_sum_beta,factor_common, &
                  b_alphaval,b_betaval,b_gammaval, &
                  NSPEC_ATTENUATION_AB, &
                  b_R_xx,b_R_yy,b_R_xy,b_R_xz,b_R_yz, &
                  b_epsilondev_xx,b_epsilondev_yy,b_epsilondev_xy, &
                  b_epsilondev_xz,b_epsilondev_yz,b_epsilon_trace_over_3, &
                  ANISOTROPY,NSPEC_ANISO, &
                  c11store,c12store,c13store,c14store,c15store,c16store,&
                  c22store,c23store,c24store,c25store,c26store,c33store,&
                  c34store,c35store,c36store,c44store,c45store,c46store,&
                  c55store,c56store,c66store, &
                  SIMULATION_TYPE, COMPUTE_AND_STORE_STRAIN,NSPEC_STRAIN_ONLY,&
                  NSPEC_BOUN,NSPEC2D_MOHO,NSPEC_ADJOINT,&
                  is_moho_top,is_moho_bot, &
                  b_dsdx_top,b_dsdx_bot, &
                  ispec2D_moho_top,ispec2D_moho_bot, &
                  num_phase_ispec_elastic,nspec_inner_elastic,nspec_outer_elastic,&
                  phase_ispec_inner_elastic )

  case default

    stop 'error no Deville routine available for chosen NGLLX'

  end select


end subroutine compute_forces_viscoelastic_Dev_sim3
